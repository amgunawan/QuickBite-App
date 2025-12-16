//
//  ActivityViewModel.swift
//  QuickBite App
//
//  Created by jessica tedja on 12/12/25.
//

import SwiftUI
import FirebaseFirestore
import Combine

final class ActivityViewModel: ObservableObject {
    
    // MARK: - PUBLISHED STATE
    @Published var historyOrders: [ActivityOrderModel] = []
    @Published var progressOrders: [ActivityOrderModel] = []
    
    // MARK: - PRIVATE
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - FETCH ORDERS (REALTIME)
    func fetchOrders() {
        
        // Hapus listener lama (hindari duplicate)
        listener?.remove()
        
        listener = db
            .collection("orders")
        // 🔥 pakai timestamp yang ADA di database kamu
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
                    
                    // 🔥 HITUNG TOTAL QUANTITY
                    let totalQuantity: Int = items.reduce(0) { result, item in
                        let number = item
                            .split(separator: "x")
                            .first
                            .flatMap { Int($0.trimmingCharacters(in: .whitespaces)) } ?? 1
                        return result + number
                    }
                    
                    // 🔥 AMBIL NAMA MAKANAN TANPA "1x"
                    let mealName: String = items.first?
                        .components(separatedBy: "x ")
                        .dropFirst()
                        .joined(separator: " ") ?? "-"
                    
                    
                    // ===== BUILD MODEL =====
                    let model = ActivityOrderModel(
                        id: doc.documentID,
                        orderId: doc.documentID,
                        status: status,
                        storeId: data["tenantId"] as? String ?? "",
                        userId: data["customerName"] as? String ?? "",
                        itemId: doc.documentID,
                        quantity: totalQuantity,
                        price: data["total"] as? Int ?? 0,
                        date: createdDate,
                        totalCost: data["total"] as? Int ?? 0,
                        restaurantName: data["restaurantName"] as? String,
                        mealName: (data["items"] as? [String])?.first,
                        rating: data["rating"] as? Int
                    )
                    
                    // ===== STATUS ROUTING =====
                    switch status {
                    case "completed", "done", "picked_up":
                        history.append(model)
                        
                    case "pending", "preparing", "ready":
                        progress.append(model)
                        
                    default:
                        // fallback → tetap tampil di In Progress
                        progress.append(model)
                    }
                }
                
                // ===== UPDATE UI =====
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
