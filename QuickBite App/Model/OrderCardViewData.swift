//
//  OrderCardViewData.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import Foundation

struct OrderCardViewData: Identifiable {
    let id: String
    let name: String
    let pickupTime: String
    let items: [String]
    let total: String
    var status: String

//    init(
//        id: UUID = UUID(),
//        name: String,
//        pickupTime: String,
//        items: [String],
//        total: String,
//        status: String
//    ) {
//        self.id = id
//        self.name = name
//        self.pickupTime = pickupTime
//        self.items = items
//        self.total = total
//        self.status = status
//    }
}

