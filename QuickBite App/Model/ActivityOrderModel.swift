//
//  ActivityOrderModel.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import Foundation
import SwiftUI

struct ActivityOrderModel: Identifiable {
    let id = UUID()
    
    let date: String
    let restaurantName: String
    let mealName: String
    let price: Int
    
    // rating = nil → user belum kasih rating
    // rating = 1...5 → user sudah rating
    var rating: Int?
}
