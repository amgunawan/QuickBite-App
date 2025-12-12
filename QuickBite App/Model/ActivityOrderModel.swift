//
//  ActivityOrderModel.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import Foundation

struct ActivityOrderModel: Identifiable {

    // 🔑 ID HARUS documentID Firestore
    let id: String
    let orderId: String

    // Status & ownership
    let status: String
    let storeId: String
    let userId: String

    // Item (ringkas untuk Activity)
    let itemId: String
    let quantity: Int
    let price: Int

    // UI
    let date: String
    let totalCost: Int

    // Optional (hasil join / future use)
    let restaurantName: String?
    let mealName: String?

    // Rating
    var rating: Int?
}
