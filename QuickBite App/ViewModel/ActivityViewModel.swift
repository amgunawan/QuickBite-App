//
//  ActivityViewModel.swift
//  QuickBite App
//
//  Created by jessica tedja on 12/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ActivityViewModel: ObservableObject {

    @Published var historyOrders: [ActivityOrderModel] = []
    @Published var progressOrders: [ActivityOrderModel] = []

    private let db = Firestore.firestore()

    // nanti ganti dari FirebaseAuth.currentUser
    private let userPath = "/users/xKU2P7crq1OOckA3tK83uHNOTwR2"

    func fetchOrders() {
        db.collection("orders")
            .whereField("user_id", isEqualTo: userPath)
            .order(by: "created_at", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }

                if let error = error {
                    print("❌ fetchOrders error:", error.localizedDescription)
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM, HH:mm"

                let orders = snapshot?.documents.compactMap { doc -> ActivityOrderModel? in
                    let d = doc.data()

                    guard
                        let status = d["status"] as? String,
                        let storeId = d["store_id"] as? String,
                        let userId = d["user_id"] as? String,
                        let totalCost = d["total_cost"] as? Int
                    else { return nil }

                    // ambil item pertama (ringkas untuk Activity)
                    guard
                        let items = d["items"] as? [[String: Any]],
                        let firstItem = items.first,
                        let itemId = firstItem["item_id"] as? String,
                        let price = firstItem["price"] as? Int,
                        let quantity = firstItem["quantity"] as? Int
                    else { return nil }

                    let createdAt = (d["created_at"] as? Timestamp)?.dateValue()
                    let dateString = createdAt != nil
                        ? formatter.string(from: createdAt!)
                        : "-"

                    return ActivityOrderModel(
                        id: doc.documentID,
                        orderId: doc.documentID,
                        status: status,
                        storeId: storeId,
                        userId: userId,
                        itemId: itemId,
                        quantity: quantity,
                        price: price,
                        date: dateString,
                        totalCost: totalCost,
                        restaurantName: nil,
                        mealName: nil,
                        rating: d["rating"] as? Int
                    )
                } ?? []

                self.historyOrders = orders.filter { $0.status == "completed" }
                self.progressOrders = orders.filter { $0.status != "completed" }
            }
    }
}
