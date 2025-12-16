//
//  ActivityViewModel.swift
//  QuickBite App
//
//  Created by jessica tedja on 12/12/25.
//

//
//  ActivityViewModel.swift
//  QuickBite App
//

import SwiftUI
import FirebaseFirestore
import Combine

class ActivityViewModel: ObservableObject {

    @Published var historyOrders: [ActivityOrderModel] = []
    @Published var progressOrders: [ActivityOrderModel] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // ================= FETCH ORDERS =================
    func fetchOrders() {

        listener?.remove()

        listener = db.collection("orders")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("🔥 Activity fetch error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else { return }

                var history: [ActivityOrderModel] = []
                var progress: [ActivityOrderModel] = []

                for doc in documents {
                    let data = doc.data()

                    let status = data["status"] as? String ?? "pending"

                    let model = ActivityOrderModel(
                        id: doc.documentID,
                        orderId: doc.documentID,
                        status: status,
                        storeId: data["tenantId"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        itemId: doc.documentID,
                        quantity: 1,
                        price: data["total"] as? Int ?? 0,
                        date: (data["createdAt"] as? Timestamp)?
                            .dateValue()
                            .formatted(date: .abbreviated, time: .shortened) ?? "-",
                        totalCost: data["total"] as? Int ?? 0,
                        restaurantName: data["restaurantName"] as? String,
                        mealName: (data["items"] as? [String])?.first,
                        rating: data["rating"] as? Int
                    )

                    // 🔥 STATUS ROUTING
                    if status == "completed" || status == "done" || status == "picked_up" {
                        history.append(model)
                    } else {
                        // pending | preparing | ready
                        progress.append(model)
                    }
                }

                DispatchQueue.main.async {
                    self.historyOrders = history
                    self.progressOrders = progress
                }
            }
    }

    deinit {
        listener?.remove()
    }
}
