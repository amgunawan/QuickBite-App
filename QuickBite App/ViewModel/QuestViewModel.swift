//
//  QuestViewModel.swift
//  QuickBite App
//
//  Created by jessica tedja on 17/12/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct Order {
    let totalCost: Int
    let tenantName: String
    let discount: Int
    let createdAt: Date
}

final class QuestViewModel: ObservableObject {
    
    // MARK: - USER DATA
    @Published var userName: String = ""
    @Published var totalPoints: Int = 0
    @Published var weeklyPoints: Int = 0
    @Published var weeklyTarget: Int = 100
    @Published var currentTier: String = "Bronze"
    
    
    // MARK: - UI STATE
    @Published var showLockedAlert: Bool = false
    
    // MARK: - LEADERBOARD
    @Published var podiumUsers: [RankUser] = []
    @Published var topUsers: [RankUser] = []
    
    // MARK: - QUEST / BADGES (sementara masih static UI)
    @Published var badges: [BadgeItem] = []
    
    // MARK: - PRIVATE
    private let db = Firestore.firestore()
    
    // MARK: - INIT
    init() {
        fetchUserData()
        fetchLeaderboard()
        fetchOrders()
    }
    
    private var leaderboardListener: ListenerRegistration?
    
    // MARK: - FETCH USER DATA
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        print("👤 FETCH USER DATA FOR UID:", userId)
        
        db.collection("users").document(userId)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    print("❌ USER SNAPSHOT ERROR:", error?.localizedDescription ?? "")
                    return
                }
                if data["total_points"] == nil {
                    self.db.collection("users").document(userId).setData([
                        "total_points": 0
                    ], merge: true)
                    return
                }
                
                print("📥 USER DATA:", data)
                
                DispatchQueue.main.async {
                    self.userName =
                    data["username"] as? String ??
                    data["full_name"] as? String ??
                    data["email"] as? String ??
                    "User"
                    
                    self.totalPoints = data["total_points"] as? Int ?? 0
                    self.weeklyPoints = data["weekly_points"] as? Int ?? 0
                    self.weeklyTarget = data["weekly_target"] as? Int ?? 100
                    let points = data["total_points"] as? Int ?? 0
                    self.currentTier = self.calculateTier(from: points)
                }
            }
    }
    
    
    func fetchLeaderboard() {
        leaderboardListener?.remove()
        
        leaderboardListener = db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .whereField("total_points", isGreaterThanOrEqualTo: 0)
            .order(by: "total_points", descending: true)
            .limit(to: 10)
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("❌ LEADERBOARD ERROR:", error.localizedDescription)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let users = documents.map { doc -> RankUser in
                    let data = doc.data()
                    let points = data["total_points"] as? Int ?? 0
                    
                    return RankUser(
                        username: "@\(data["username"] as? String ?? "user")",
                        points: points,
                        tier: self.calculateTier(from: points)
                    )
                }
                
                DispatchQueue.main.async {
                    self.podiumUsers = Array(users.prefix(3))
                    self.topUsers = users
                }
            }
    }
    
    func fetchOrders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("orders")
            .whereField("user_id", isEqualTo: userId)
            .whereField("status", isEqualTo: "completed")
            .getDocuments { snap, _ in
                guard let docs = snap?.documents else { return }
                
                let orders = docs.compactMap { doc -> Order? in
                    let d = doc.data()
                    let status = d["status"] as? String ?? ""
                    return Order(
                        totalCost: d["totalCost"] as? Int ?? 0,
                        tenantName: d["tenantName"] as? String ?? "",
                        discount: d["totalDiscountAmount"] as? Int ?? 0,
                        createdAt: (d["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                
                DispatchQueue.main.async {
                    self.badges = self.buildBadgesFromHistory(orders)
                }
            }
        
    }
    
    // MARK: - POINT RULE (Rp20.000 = 10 pts)
    func addPoints(from totalPrice: Int) {
        let earnedPoints = (totalPrice / 20_000) * 10
        guard earnedPoints > 0 else { return }
        
        totalPoints += earnedPoints
        weeklyPoints += earnedPoints
        
        let newTier = calculateTier(from: totalPoints)
        if newTier != currentTier {
            currentTier = newTier
        }
        
        saveUserPoints()
    }
    
    func nextTierLabel() -> String {
        switch currentTier {
        case "Bronze":
            return "Next tier: Gold"
        case "Gold":
            return "Next tier: Silver"
        case "Silver":
            return "Next tier: Diamond"
        case "Diamond":
            return "Max tier reached"
        default:
            return ""
        }
    }
    
    // MARK: - TIER CALCULATION
    func calculateTier(from points: Int) -> String {
        switch points {
        case 0...250:
            return "Bronze"
        case 251...500:
            return "Gold"
        case 501...750:
            return "Silver"
        case 751...1000:
            return "Diamond"
        default:
            return "Diamond"
        }
    }
    
    // MARK: - SAVE TO FIRESTORE
    private func saveUserPoints() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).setData([
            "total_points": totalPoints,
            "weekly_points": weeklyPoints,
            "current_tier": currentTier
        ], merge: true)
    }
    
    // MARK: - BADGE ACTION
    func tapBadge(_ badge: BadgeItem) {
        if badge.current == 0 {
            showLockedAlert = true
        }
    }
    
    private func buildBadgesFromHistory(_ orders: [Order]) -> [BadgeItem] {
        
        // 1. BEGINNER BADGE (4/4)
        // Rule:
        // Dalam 1 hari, jika ADA minimal 1 transaksi ≥ 50.000
        // maka progress +1 (max 4)

        let dailyGroups = Dictionary(grouping: orders) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }

        let qualifiedDays = dailyGroups.values.filter { dailyOrders in
            dailyOrders.contains { $0.totalCost >= 50_000 }
        }.count

        let beginnerProgress = min(qualifiedDays, 4)

        
        // 2. EXPLORER BADGE (3/3)
        // Rp150K at 3 tenants

        let tenants = Set(orders.map { $0.tenantName })
        let totalSpend = orders.reduce(0) { $0 + $1.totalCost }
        
        let explorerProgress =
        (tenants.count >= 3 && totalSpend >= 150_000) ? 3 : 0
        
        // 3. CHALLENGE BADGE (5/5)
        // 5 deals in 3 days

        let dealOrders = orders.filter { $0.discount > 0 }

        let dealDailyGroups = Dictionary(grouping: dealOrders) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }

        let challengeProgress = min(
            dealDailyGroups.values.filter { $0.count >= 5 }.count,
            5
        )
        
        // 4. LOYALTY BADGE (7/7)
        // Mon–Fri purchases for 7 weeks

        let weeklyOrders = Dictionary(grouping: orders) {
            Calendar.current.component(.weekOfYear, from: $0.createdAt)
        }
        
        var validWeeks = 0
        for week in weeklyOrders.values {
            let weekdays = Set(week.map {
                Calendar.current.component(.weekday, from: $0.createdAt)
            })
            let requiredDays = [2,3,4,5,6] // Mon–Fri
            if requiredDays.allSatisfy(weekdays.contains) {
                validWeeks += 1
            }
        }
        
        let loyaltyProgress = min(validWeeks, 7)
        
        // RETURN BADGES
        return [
            BadgeItem(
                title: "Beginner Badges",
                subtitle: "Spend min. Rp50K to earn 30 pts.",
                current: beginnerProgress,
                target: 4,
                rewardPts: 30,
                tint: .orange
            ),
            BadgeItem(
                title: "Explorer Badges",
                subtitle: "Spend Rp150K total at 3 tenants.",
                current: explorerProgress,
                target: 3,
                rewardPts: 200,
                tint: .blue
            ),
            BadgeItem(
                title: "Challenge Badges",
                subtitle: "Grab 5 Last Call items in 3 days.",
                current: challengeProgress,
                target: 5,
                rewardPts: 300,
                tint: .pink
            ),
            BadgeItem(
                title: "Loyalty Badges",
                subtitle: "Keep a 7-day streak.",
                current: loyaltyProgress,
                target: 7,
                rewardPts: 650,
                tint: .green
            )
        ]
    }
    
//    private func loadBadges() {
//        badges = buildBadgesFromHistory([])
//    }
    
}
