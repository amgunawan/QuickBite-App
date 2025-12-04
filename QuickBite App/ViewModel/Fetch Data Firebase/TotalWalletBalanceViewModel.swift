//
//  TodayIncomeViewModel.swift
//  QuickBite
//
//  Created by Angela on 04/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class TotalWalletBalanceViewModel: ObservableObject {
    @Published var totalWalletBalance: Int = 0
    private let db = Firestore.firestore()
    
    func fetchWalletBalance(storeId: String) {
        let storeRef = db.collection("stores").document(storeId)

        db.collection("orders")
            .whereField("store_id", isEqualTo: storeRef)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Firestore error:", error)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                var balance = 0

                for doc in documents {
                    let status = doc.get("status") as? String ?? ""
                    let cost = doc.get("total_cost") as? Int ?? 0

                    if status == "completed" {
                        balance += cost
                    }
                }

                DispatchQueue.main.async {
                    self.totalWalletBalance = balance
                }
            }
    }
}
