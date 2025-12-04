//
//  MenuItemModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation

struct MenuItemModel: Identifiable, Codable {
    var id: String
    var name: String
    var description: String?
    var price: Int
    var category: String?
    
    var imageURL: String?
    
    var defaultStock: Int?
    var prepTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "item_id"
        case name
        case description
        case price
        case category
        case imageURL = "image_url" 
        case defaultStock = "default_stock"
        case prepTime = "prep_time_minutes"
    }
}
