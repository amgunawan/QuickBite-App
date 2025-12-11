//
//  MenuItemUploadModel.swift
//  QuickBite
//
//  Created by student on 05/12/25.
//

import Foundation

struct MenuItemUploadModel: Codable {
    let item_id: String
    let name: String
    let description: String
    let price: Int
    let default_stock: Int
    let prep_time_minutes: Int
    let category: String
    let image_url: String
}
