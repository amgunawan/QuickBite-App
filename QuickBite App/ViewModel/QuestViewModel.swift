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

final class QuestViewModel: ObservableObject {
    
    // MARK: - USER DATA
    @Published var userName: String = "User"
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
        loadBadges()
    }
    
    // MARK: - FETCH USER DATA
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            
            DispatchQueue.main.async {
                self.userName = data["username"] as? String ?? "User"
                self.totalPoints = data["total_points"] as? Int ?? 0
                self.weeklyPoints = data["weekly_points"] as? Int ?? 0
                self.weeklyTarget = data["weekly_target"] as? Int ?? 100
                self.currentTier = data["current_tier"] as? String ?? "Bronze"
            }
        }
    }
    
    // MARK: - FETCH LEADERBOARD (REAL DATA)
    func fetchLeaderboard() {
        db.collection("users")
            .whereField("role", isEqualTo: "customer")
            .order(by: "total_points", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ ERROR:", error.localizedDescription)
                    return
                }
                
                print("✅ DOC COUNT:", snapshot?.documents.count ?? 0)
                
                let users = snapshot?.documents.map { doc -> RankUser in
                    let data = doc.data()
                    return RankUser(
                        username: "@\(data["username"] as? String ?? "user")",
                        points: data["total_points"] as? Int ?? 0,
                        tier: data["current_tier"] as? String ?? "Bronze"
                    )
                } ?? []
                
                DispatchQueue.main.async {
                    self.podiumUsers = Array(users.prefix(3))
                    self.topUsers = users
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
        fetchLeaderboard()
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
        
        db.collection("users").document(userId).updateData([
            "total_points": totalPoints,
            "weekly_points": weeklyPoints,
            "current_tier": currentTier
        ])
    }
    
    // MARK: - BADGE ACTION
    func tapBadge(_ badge: BadgeItem) {
        if badge.current == 0 {
            showLockedAlert = true
        }
    }
    
    // MARK: - BADGES (UI ONLY, LOGIC NEXT STEP)
    private func loadBadges() {
        badges = [
            .init(title: "Beginner Badges",
                  subtitle: "Spend min. Rp50K to earn 30 pts.",
                  current: 1, target: 3, rewardPts: 30, tint: .orange),
            .init(title: "Explorer Badges",
                  subtitle: "Spend Rp150K total at 3 tenants.",
                  current: 0, target: 5, rewardPts: 200, tint: .blue),
            .init(title: "Challenge Badges",
                  subtitle: "Grab 5 Last Call items in 3 days.",
                  current: 0, target: 5, rewardPts: 300, tint: .pink),
            .init(title: "Loyalty Badges",
                  subtitle: "Keep a 7-day streak.",
                  current: 0, target: 7, rewardPts: 650, tint: .green)
        ]
    }
}
