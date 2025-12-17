//
// ActivityViewModel.swift
// QuickBite App
//
// Created by jessica tedja on 12/12/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
class ActivityViewModel: ObservableObject {
    @Published var progressOrders: [ActivityOrderModel] = []
    @Published var historyOrders: [ActivityOrderModel] = []
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    /// Mengambil data order berdasarkan User ID dan memfilternya
    func fetchOrders(for userId: String) {
        let userRef = db.collection("users").document(userId)
        
        db.collection("orders")
            .whereField("user_id", isEqualTo: userRef)
            .order(by: "created_at", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                var orders = documents.compactMap { doc -> ActivityOrderModel? in
                    try? doc.data(as: ActivityOrderModel.self)
                }
                
                let group = DispatchGroup()
                for i in 0..<orders.count {
                    if let storeRef = orders[i].storeId {
                        group.enter()
                        storeRef.getDocument { storeDoc, _ in
                            if let storeData = storeDoc?.data() {
                                // 1. Ambil Nama
                                orders[i].restaurantName = storeData["name"] as? String
                                // 2. Ambil gs:// url dan ubah ke HTTPS
                                if let gsURL = storeData["search_url"] as? String {
                                    let storageRef = self.storage.reference(forURL: gsURL)
                                    storageRef.downloadURL { url, _ in
                                        orders[i].storeSearchImageURL = url?.absoluteString
                                        group.leave()
                                    }
                                } else {
                                    group.leave()
                                }
                            } else {
                                group.leave()
                            }
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    // Filter murni berdasarkan status
                    self.progressOrders = orders.filter { $0.status == "pending" || $0.status == "ready" }
                    self.historyOrders = orders.filter { $0.status == "completed" }
                }
            }
        
    }
    /// Fungsi untuk mengupdate rating di Firestore
    func updateRating(orderId: String, rating: Int) {
        db.collection("orders").document(orderId).updateData([ "rating": rating ]) {
            error in if let error = error { print("Error updating rating: \(error.localizedDescription)")
            }
        }
    }
}
