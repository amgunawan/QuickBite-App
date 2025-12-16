//
//  ActivityOrderModel.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

//
//  ActivityOrderModel.swift
//  QuickBite
//

import Foundation

struct ActivityOrderModel: Identifiable {

    let id: String
    let orderId: String

    let status: String
    let storeId: String
    let userId: String

    let itemId: String
    let quantity: Int
    let price: Int

    let date: String
    let totalCost: Int

    let restaurantName: String?
    let mealName: String?

    var rating: Int?

    // ✅ CUSTOM INIT (FIX ERROR)
    init(
        id: String,
        orderId: String,
        status: String,
        storeId: String,
        userId: String,
        itemId: String,
        quantity: Int,
        price: Int,
        date: String,
        totalCost: Int,
        restaurantName: String?,
        mealName: String?,
        rating: Int?
    ) {
        self.id = id
        self.orderId = orderId
        self.status = status
        self.storeId = storeId
        self.userId = userId
        self.itemId = itemId
        self.quantity = quantity
        self.price = price
        self.date = date
        self.totalCost = totalCost
        self.restaurantName = restaurantName
        self.mealName = mealName
        self.rating = rating
    }
}
