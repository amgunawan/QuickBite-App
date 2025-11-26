//
//  OrderCardViewData.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import Foundation

struct OrderCardViewData {
    let id = UUID()
    let name: String
    let pickupTime: String
    let items: [String]
    let total: String
}
