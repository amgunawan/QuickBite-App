//
//  InProgressOrderModel.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import Foundation
struct InProgressOrderModel: Identifiable {
    let id = UUID()
    
    let date: String
    let restaurantName: String
    let mealName: String
    let price: Int
    
    // isReady = false → OrderPreparedView
    // isReady = true → OrderPickUpView
    let isReady: Bool
}
