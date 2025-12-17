//
//  ActivityOrderModel.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//


import Foundation

struct ActivityOrderModel: Identifiable {

    let id: String
    let status: String
    let storeId: String
    let userId: String

    let itemId: String
    let quantity: Int
    let price: Int

    let date: String
    let totalCost: Int

    var restaurantImageURL: String?   // ✅ TAMBAH INI
    let restaurantName: String?
    let mealName: String?

    var rating: Int?

    // ✅ CUSTOM INIT (FIX ERROR)
    init(
        id: String,
        status: String,
        storeId: String,
        userId: String,
        itemId: String,
        quantity: Int,
        price: Int,
        date: String,
        totalCost: Int,
        restaurantName: String?,
        restaurantImageURL: String?,
        mealName: String?,
        rating: Int?
    ) {
        self.id = id
        self.status = status
        self.storeId = storeId
        self.userId = userId
        self.itemId = itemId
        self.quantity = quantity
        self.price = price
        self.date = date
        self.totalCost = totalCost
        self.restaurantName = restaurantName
        self.restaurantImageURL = restaurantImageURL
        self.mealName = mealName
        self.rating = rating
    }
}
