//
//  TenantActivityViewModel.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import Combine
import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class TenantActivityViewModel: ObservableObject {
    
    @Published var newOrders: [OrderCardViewData] = []
    @Published var preparingOrders: [OrderCardViewData] = []
    @Published var readyOrders: [OrderCardViewData] = []
    @Published var historyOrders: [OrderCardViewData] = []
    
    private var menuNameMap: [String: String] = [:]
    private var menuNameCache: [String: String] = [:]

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func startListening(storeId: String) {
        listener?.remove()
        
        let storeRef = db.collection("stores").document(storeId)
        
        listener = db.collection("orders")
            .whereField("store_id", isEqualTo: storeRef)
            .order(by: "created_at", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self,
                      let docs = snapshot?.documents else { return }
                
                Task { @MainActor in
                    var allOrders: [OrderCardViewData] = []
                    
                    for doc in docs {
                        let data = doc.data()
                        
                        let status = data["status"] as? String ?? "new"
                        let pickupDate = (data["pickup_time"] as? Timestamp)?.dateValue()
                        let totalInt = data["total_cost"] as? Int ?? 0
                        
                        let rawItems = data["items"] as? [[String: Any]] ?? []
                        let parsedItems = await self.parseItems(rawItems, storeId: storeId)
                        
                        let userRef = data["user_id"] as? DocumentReference
                        let customerName = userRef != nil
                        ? await self.fetchCustomerName(from: userRef!)
                        : "Customer"
                        
                        let order = OrderCardViewData(
                            id: doc.documentID,
                            name: customerName,
                            pickupTime: formatTime(pickupDate),
                            items: parsedItems,
                            total: "Rp \(formatPrice(Double(totalInt)))",
                            status: status
                        )
                        
                        allOrders.append(order)
                    }
                    
                    self.newOrders       = allOrders.filter { $0.status == "new" }
                    self.preparingOrders = allOrders.filter { $0.status == "preparing" }
                    self.readyOrders     = allOrders.filter { $0.status == "ready_for_pickup" }
                    self.historyOrders   = allOrders.filter { $0.status == "completed" }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func updateStatus(orderId: String, to newStatus: String) {
        db.collection("orders").document(orderId).updateData([
            "status": newStatus
        ])
    }
    
    private func fetchCustomerName(from ref: DocumentReference) async -> String {
        do {
            let snap = try await ref.getDocument()
            return snap.data()?["username"] as? String
            ?? snap.data()?["full_name"] as? String
            ?? "Customer"
        } catch {
            return "Customer"
        }
    }
    
    private func fetchMenuName(
        itemId: String,
        storeId: String
    ) async -> String {

        // ✅ CACHE FIRST
        if let cached = menuNameCache[itemId] {
            return cached
        }

        do {
            let storeSnap = try await db
                .collection("stores")
                .document(storeId)
                .getDocument()

            guard let menuURL = storeSnap.data()?["menu_data_url"] as? String else {
                return itemId
            }

            let storageRef = Storage.storage().reference(forURL: menuURL)
            let data = try await downloadData(from: storageRef)

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let sections = json?["sections"] as? [[String: Any]] ?? []

            for section in sections {
                let items = section["items"] as? [[String: Any]] ?? []
                for menu in items {
                    if let id = menu["item_id"] as? String,
                       let name = menu["name"] as? String {
                        menuNameCache[id] = name
                    }
                }
            }

            return menuNameCache[itemId] ?? itemId
        } catch {
            return itemId
        }
    }
    
    private func downloadData(from ref: StorageReference) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }

    
    private func parseItems(
        _ rawItems: [[String: Any]],
        storeId: String
    ) async -> [String] {

        var result: [String] = []

        for item in rawItems {
            let qty = item["quantity"] as? Int ?? 1
            let itemId = item["item_id"] as? String ?? ""

            let menuName = await fetchMenuName(
                itemId: itemId,
                storeId: storeId
            )

            // ✅ MENU UTAMA
            result.append("\(qty)x \(menuName)")

            // ✅ ADDITIONAL OPTIONS (tanpa category)
            let options = item["additional_options"] as? [[String: Any]] ?? []
            for opt in options {
                let choices = opt["selected_choice"] as? [[String: Any]] ?? []
                for choice in choices {
                    if let name = choice["name"] as? String {
                        result.append(name)
                    }
                }
            }

            result.append("") // spasi antar menu
        }

        return result.dropLast()
    }


    
    
    deinit { listener?.remove() }
}
