////
////  MenuItemModel.swift
////  QuickBite
////
////  Created by student on 04/12/25.
////
//
//import Foundation
//
//struct MenuItemModel: Identifiable, Codable {
//    var id: String
//    var name: String
//    var description: String?
//    var price: Int
//    var category: String?
//    
//    var imageURL: String?
//    
//    var defaultStock: Int?
//    var prepTime: Int?
//    
//    var options: [MenuOptionCategory]?
//    
//    var nonOptionalOptions: [MenuOptionCategory] {
//        return options ?? []
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "item_id"
//        case name
//        case description
//        case price
//        case category
//        case imageURL = "image_url" 
//        case defaultStock = "default_stock"
//        case prepTime = "prep_time_minutes"
//        case options
//    }
//}
//
//struct MenuOptionChoice: Codable, Hashable {
//    var name: String
//    var price: Int // additional_price
//    
//    enum CodingKeys: String, CodingKey {
//        case name
//        case price = "additional_price"
//    }
//}
//
//struct MenuOptionCategory: Codable, Identifiable {
//    var id = UUID()
//    var category: String // Nama kategori
//    var minSelect: Int
//    var maxSelect: Int
//    var choices: [MenuOptionChoice]
//    
//    enum CodingKeys: String, CodingKey {
//        case category
//        case minSelect = "min_select"
//        case maxSelect = "max_select"
//        case choices
//    }
//}
