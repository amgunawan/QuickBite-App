//
//  OrderViewModel.swift
//  QuickBite
//
//  Created by Jessica Tedja on 12/12/25
//

//
//  OrderViewModel.swift
//  QuickBite
//

import SwiftUI
import FirebaseFirestore
import Combine

class OrderViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    // ============================
    // CREATE ORDER → FIRESTORE
    // ============================
    func createOrder(
        from cart: CartViewModel,
        completion: @escaping (String?) -> Void
    ) {

        guard !cart.items.isEmpty else {
            completion(nil)
            return
        }

        isLoading = true
        errorMessage = nil

        let itemsData: [[String: Any]] = cart.items.map { item in
            [
                "menuId": item.id.uuidString,
                "name": item.name,
                "price": item.currentPrice,
                "quantity": item.quantity,
                "options": item.optionsDescription
            ]
        }

        let orderData: [String: Any] = [
            "restaurantId": cart.restaurantId,
            "restaurantName": cart.restaurantName,
            "items": itemsData,
            "totalPrice": cart.totalPrice,
            "status": "pending",
            "createdAt": Timestamp()
        ]

        let docRef = db.collection("orders").document()

        docRef.setData(orderData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(nil)
                } else {
                    completion(docRef.documentID) // ⬅️ ORDER ID UNTUK QR
                }
            }
        }
    }
}
