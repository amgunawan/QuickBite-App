//
//  OrderService.swift
//  QuickBite App
//
//  Created by student on 03/12/25.
//

import FirebaseFirestore

class OrderService {
    private let db = Firestore.firestore()

    func createOrder(customerName: String,
                     items: [String],
                     total: Int,
                     pickupTime: String,
                     tenantId: String,
                     userId: String,
                     completion: @escaping (String?) -> Void) {

        // Generate Firestore auto-ID
        let orderId = db.collection("orders").document().documentID

        // Build order data
        let data: [String: Any] = [
            "order_id": orderId,
            "customerName": customerName,
            "items": items,
            "total": total,
            "pickupTime": pickupTime,
            "tenantId": tenantId,
            "user_id": db.collection("users").document(userId),
            "status": "pending",
            "created_at": FieldValue.serverTimestamp(),
            "timestamp": Int(Date().timeIntervalSince1970),
        ]

        // Save to Firestore
        db.collection("orders").document(orderId).setData(data) { error in
            if let error = error {
                print("❌ Error creating order: \(error.localizedDescription)")
                completion(nil)
            } else {
                print("Order created with ID: \(orderId)")
                completion(orderId)
            }
        }
    }
}
