//
//  MenuData.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import Foundation

struct OptionChoice: Codable, Identifiable {
    let id = UUID()
    let name: String
    let additionalPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case name
        case additionalPrice = "additional_price"
    }
}

struct OptionCategory: Codable, Identifiable {
    let id = UUID()
    let category: String
    let minSelect: Int
    let maxSelect: Int
    let choices: [OptionChoice]
    
    enum CodingKeys: String, CodingKey {
        case category
        case minSelect = "min_select"
        case maxSelect = "max_select"
        case choices
    }
}

//struct MenuItemData: Codable, Identifiable {
//    let id: String
//    let name: String
//    let description: String
//    let price: Double
//    let defaultStock: Int
//    let prepTimeMinutes: Int
//    let category: String
//    let imageUrl: String
//    let options: [OptionCategory]
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "item_id"
//        case name
//        case description
//        case price
//        case defaultStock = "default_stock"
//        case prepTimeMinutes = "prep_time_minutes"
//        case category
//        case imageUrl = "image_url"
//        case options
//    }
//    
//    var salesDescription: String { return "Tersedia \(defaultStock)" }
//    var originalPrice: Double? { return nil }
//    var longDescription: String { return description }
//}

//struct MenuCategoryData: Identifiable {
//    let id = UUID()
//    let title: String
//    var items: [MenuItemData]
//}
