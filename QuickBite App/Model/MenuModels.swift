//
//  MenuModels.swift
//  QuickBite
//
//  Created by student on 11/12/25.
//

import Foundation
import SwiftUI

// MARK: - Firestore Tracking Stock

struct TrackingItem: Codable, Hashable {
    var itemId: String
    var currentStock: Int
    var totalSold: Int
    
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case currentStock = "current_stock"
        case totalSold = "total_sold"
    }
}

// MARK: - Stock Status for UI

enum StockStatus: String, Codable {
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
}

// MARK: - Menu Options (Customization)

struct MenuChoice: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var additionalPrice: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case additionalPrice = "additional_price"
    }
}

struct MenuOptionGroup: Codable, Identifiable, Hashable {
    var id = UUID()
    var category: String          // Example: "Topping"
    var minSelect: Int            // JSON: min_select
    var maxSelect: Int            // JSON: max_select
    var choices: [MenuChoice]
    
    enum CodingKeys: String, CodingKey {
        case category
        case minSelect = "min_select"
        case maxSelect = "max_select"
        case choices
    }
}

// MARK: - Menu Item (Firebase Storage menu.json)

struct MenuItem: Identifiable, Codable, Hashable {
    
    // JSON fields
    var itemId: String
    var name: String
    var description: String
    var price: Int
    var defaultStock: Int
    var prepTimeMinutes: Int
    var category: String
    var imageURL: String
    var options: [MenuOptionGroup]
    
    // Runtime field (merged with tracking_item)
    var currentStock: Int = 0
    
    var id: String { itemId }
    
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case name
        case description
        case price
        case defaultStock = "default_stock"
        case prepTimeMinutes = "prep_time_minutes"
        case category
        case imageURL = "image_url"
        case options
    }
    
    // MARK: - Stock Status UI Helper
    var stockStatus: StockStatus {
        if currentStock <= 0 { return .outOfStock }
        if currentStock <= 5 { return .lowStock }
        return .inStock
    }
    
    // MARK: - Extract filename of storage image
    var imageFileName: String {
        URL(string: imageURL)?.lastPathComponent ?? ""
    }
    
    // MARK: - Extract folder name from menu_data_url (store folder)
    static func extractStoreFolder(from menuDataURL: String) -> String? {
        // gs://bucket/<storeFolder>/menu.json
        let components = URL(string: menuDataURL)?.pathComponents ?? []
        if components.count >= 2 {
            return components[components.count - 2] // folder name
        }
        return nil
    }
}

// MARK: - Section Model (for UI)

struct MenuSectionModel: Identifiable, Hashable {
    let id = UUID()
    var title: String        // category
    var items: [MenuItem]
}
