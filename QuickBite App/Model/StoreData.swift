//
//  StoreData.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import Foundation

struct StoreData: Identifiable {
    let id: String
    let name: String
    let rating: Double
    let reviewCount: Int
    let categories: [String]
    let location: String
    let storeSchedule: [String: ScheduleData]
}

struct ScheduleData: Decodable {
    let openTime: String
    let closeTime: String
    
    enum CodingKeys: String, CodingKey {
        case openTime = "open_time"
        case closeTime = "close_time"
    }
}
