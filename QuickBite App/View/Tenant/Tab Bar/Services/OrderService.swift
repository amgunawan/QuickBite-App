//
//  OrderService.swift
//  QuickBite App
//
//  Created by student on 03/12/25.
//

import FirebaseFirestore

final class OrderService {

    private let db = Firestore.firestore()

    func createOrder(
        cartItems: [CartItemModel],
        storeId: String,
        pickupDate: Date,
        totalCost: Int,
        userId: String,
        isGroupOrder: Bool,
        completion: @escaping (String?) -> Void
    ) {

        let orderRef = db.collection("orders").document()

        let userRef = db.collection("users").document(userId)
        let storeRef = db.collection("stores").document(storeId)

        // ✅ Build items array in correct Firestore structure
        let items: [[String: Any]] = cartItems.map { item in
            [
                "item_id": item.menuItemId,
                "price": Int(item.currentPrice),
                "quantity": item.quantity,
                "preptime_min": item.prepTime,
                "preptime_max": (item.prepTime ?? 0) + 10,
                "additional_options": [] // future-proof
            ]
        }

        let data: [String: Any] = [
            "created_at": Timestamp(date: Date()),
            "items": items,
            "order_type": isGroupOrder ? "group" : "individual",
            "pickup_time": Timestamp(date: pickupDate),
            "qr_code": "",
            "status": "pending",
            "store_id": storeRef,
            "total_cost": totalCost,
            "user_id": userRef
        ]

        orderRef.setData(data) { error in
            if let error {
                print("❌ Error creating order:", error.localizedDescription)
                completion(nil)
            } else {
                print("✅ Order created:", orderRef.documentID)
                completion(orderRef.documentID)
            }
        }
    }
}
