//
//  DiscountModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation
import FirebaseFirestore

struct DiscountModel: Identifiable, Codable {
    @DocumentID var id: String?
    
    var amount: Int
    var itemId: String
    var startDateTime: Date
    var endDateTime: Date
    var storeId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount = "discount_amount"
        case itemId = "item_id"
        case startDateTime = "start_date_time"
        case endDateTime = "end_date_time"
        case storeId = "store_id"
    }
    
    // Helper untuk mengecek apakah diskon SEDANG BERLAKU sekarang
    var isActive: Bool {
        let now = Date()
        return now >= startDateTime && now <= endDateTime
    }
    
    init(id: String?, amount: Int, itemId: String, startDateTime: Date, endDateTime: Date, storeId: String) {
        self.id = id
        self.amount = amount
        self.itemId = itemId
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.storeId = storeId
    }
}


