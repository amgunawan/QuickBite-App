//
//  MenuModels.swift
//  QuickBite
//

import Foundation
import SwiftUI

// MARK: - Menu Item

struct MenuItem: Identifiable, Codable, Hashable {

    // MARK: JSON Fields
    var itemId: String
    var name: String
    var description: String?
    var price: Int
    var category: String?
    var imageURL: String?
    var defaultStock: Int?
    var prepTimeMinutes: Int?
    var options: [MenuOptionGroup]?

    // MARK: Runtime-only
    var draftImage: UIImage? = nil
    var currentStock: Int = 0
    var totalSold: Int = 0
    
    // MARK: - Stock Status (UI Helper)
    var stockStatus: StockStatus {
        if currentStock <= 0 { return .outOfStock }
        if currentStock <= 5 { return .lowStock }
        return .inStock
    }

    var id: String { itemId }

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case name
        case description
        case price
        case category
        case imageURL = "image_url"
        case defaultStock = "default_stock"
        case prepTimeMinutes = "prep_time_minutes"
        case options
    }

    var nonOptionalOptions: [MenuOptionGroup] {
        options ?? []
    }
}

// MARK: - Menu Option Group

struct MenuOptionGroup: Codable, Identifiable, Hashable {
    var id = UUID()
    var category: String
    var minSelect: Int
    var maxSelect: Int
    var choices: [MenuOptionChoice]

    enum CodingKeys: String, CodingKey {
        case category
        case minSelect = "min_select"
        case maxSelect = "max_select"
        case choices
    }
}

// MARK: - Menu Option Choice

struct MenuOptionChoice: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var additionalPrice: Int

    enum CodingKeys: String, CodingKey {
        case name
        case additionalPrice = "additional_price"
    }
}

// MARK: - Menu Section

struct MenuSectionModel: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var items: [MenuItem]
}

enum StockStatus: String, Codable {
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
}

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
