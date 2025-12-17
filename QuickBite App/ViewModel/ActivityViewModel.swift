//
//  ActivityViewModel.swift
//  QuickBite App
//
//  Created by jessica tedja on 12/12/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Combine

final class ActivityViewModel: ObservableObject {

    // MARK: - PUBLISHED STATE
    @Published var historyOrders: [ActivityOrderModel] = []
    @Published var progressOrders: [ActivityOrderModel] = []

    // MARK: - PRIVATE
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?

    // MARK: - FETCH ORDERS (REALTIME)
    func fetchOrders() {

        listener?.remove()

        listener = db
            .collection("orders")
            .order(by: "created_at", descending: true)
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

                    // ===== BASIC FIELDS =====
                    let status = (data["status"] as? String ?? "pending").lowercased()

                    let createdDate: String = {
                        if let ts = data["created_at"] as? Timestamp {
                            return ts.dateValue().formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        }
                        return "-"
                    }()

                    let items = data["items"] as? [String] ?? []

                    // ===== TOTAL QUANTITY =====
                    let totalQuantity = items.reduce(0) { sum, item in
                        let qty = item
                            .split(separator: "x")
                            .first
                            .flatMap { Int($0.trimmingCharacters(in: .whitespaces)) } ?? 1
                        return sum + qty
                    }

                    // ===== MEAL NAME =====
                    let mealName = items.first?
                        .components(separatedBy: "x ")
                        .dropFirst()
                        .joined(separator: " ") ?? "-"

                    // ===== BUILD BASE MODEL (IMAGE NIL DULU) =====
                    var model = ActivityOrderModel(
                        id: doc.documentID,
                        status: status,
                        storeId: data["tenantId"] as? String ?? "",
                        userId: data["customerId"] as? String ?? "",
                        itemId: doc.documentID,
                        quantity: totalQuantity,
                        price: data["total"] as? Int ?? 0,
                        date: createdDate,
                        totalCost: data["total"] as? Int ?? 0,
                        restaurantName: data["restaurantName"] as? String,
                        restaurantImageURL: nil,
                        mealName: mealName,
                        rating: data["rating"] as? Int
                    )

                    // ===== STATUS ROUTING =====
                    let targetArrayIsHistory =
                        status == "completed" ||
                        status == "done" ||
                        status == "picked_up"

                    if targetArrayIsHistory {
                        history.append(model)
                    } else {
                        progress.append(model)
                    }

                    // ===== HANDLE IMAGE (gs:// → https) =====
                    if let gsURL = data["search_url"] as? String {

                        let storageRef = self.storage.reference(forURL: gsURL)

                        storageRef.downloadURL { url, _ in
                            guard let httpsURL = url?.absoluteString else { return }

                            DispatchQueue.main.async {

                                if targetArrayIsHistory,
                                   let index = history.firstIndex(where: { $0.id == model.id }) {
                                    history[index].restaurantImageURL = httpsURL
                                }

                                if !targetArrayIsHistory,
                                   let index = progress.firstIndex(where: { $0.id == model.id }) {
                                    progress[index].restaurantImageURL = httpsURL
                                }

                                self.historyOrders = history
                                self.progressOrders = progress
                            }
                        }
                    }
                }

                // ===== UPDATE UI (BASE DATA) =====
                DispatchQueue.main.async {
                    self.historyOrders = history
                    self.progressOrders = progress
                }
            }
    }

    // MARK: - CLEANUP
    deinit {
        listener?.remove()
    }
}
