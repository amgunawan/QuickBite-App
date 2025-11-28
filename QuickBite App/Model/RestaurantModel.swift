//
//  RestaurantModel.swift
//  QuickBite
//
//  Created by Angela on 28/11/25.
//

import Foundation

struct Restaurant: Identifiable, Codable {
    var id: String
    var name: String
    var rating: Double
    var reviewCount: Int
    var bannerURL: String?
    var searchURL: String?
    var cuisineType: [String]
}
