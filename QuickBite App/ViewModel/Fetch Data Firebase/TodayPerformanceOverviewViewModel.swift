//
//  TodayIncomeViewModel.swift
//  QuickBite
//
//  Created by Angela on 04/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class TodayPerformanceOverviewViewModel: ObservableObject {
    @Published var totalIncomeToday: Int = 0
    @Published var totalOrdersToday: Int = 0           // completed only
    @Published var totalPendingOrdersToday: Int = 0    // not completed

    private let db = Firestore.firestore()

    func fetchTodayStats(storeId: String) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let storeRef = db.collection("stores").document(storeId)

        db.collection("orders")
            .whereField("store_id", isEqualTo: storeRef)
            .whereField("created_at", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("created_at", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Firestore error:", error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }

                var income = 0
                var completedCount = 0
                var pendingCount = 0

                for doc in documents {
                    let status = doc.get("status") as? String ?? ""
                    let cost = doc.get("total_cost") as? Int ?? 0

                    if status == "completed" {
                        income += cost
                        completedCount += 1
                    } else {
                        pendingCount += 1
                    }
                }

                DispatchQueue.main.async {
                    self.totalIncomeToday = income
                    self.totalOrdersToday = completedCount
                    self.totalPendingOrdersToday = pendingCount
                }
            }
    }
}
