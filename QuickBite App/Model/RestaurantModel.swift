//
//  RestaurantModel.swift
//  QuickBite
//
//  Created by Angela on 28/11/25.
//

import Foundation
import FirebaseFirestore

struct Restaurant: Identifiable, Codable {
    
    // 1. Gunakan @DocumentID agar ID dokumen (misal "RABURI") otomatis masuk sini
    @DocumentID var id: String?
    
    var name: String
    var location: String?
    var rating: Double
    var reviewCount: Int
    var bannerURL: String?
    var searchURL: String?
    var cuisineType: [String]
    var menuDataURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case rating
        
        case reviewCount = "review_count"
        case bannerURL = "banner_url"
        case searchURL = "search_url"
        case cuisineType = "cuisine_type"
        case menuDataURL = "menu_data_url"
    }
}
