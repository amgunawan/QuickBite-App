//
//  RestaurantModel.swift
//  QuickBite
//
//  Created by Angela on 28/11/25.
//

import Foundation
import FirebaseFirestore

struct Restaurant: Identifiable, Codable {

    // MARK: - Identity
    @DocumentID var id: String?

    // MARK: - Core Info
    var name: String
    var location: String
    var cuisineType: [String]

    // MARK: - Media
    var bannerURL: String?
    var searchURL: String?
    var menuDataURL: String?

    // MARK: - Ratings
    var rating: Double
    var reviewCount: Int

    // MARK: - Optional / Backend-Controlled
    var deliveryTime: String?
    var storeSchedule: [String: DailySchedule]?

    // MARK: - Firestore Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case cuisineType      = "cuisine_type"

        case bannerURL        = "banner_url"
        case searchURL        = "search_url"
        case menuDataURL      = "menu_data_url"

        case rating
        case reviewCount      = "review_count"
        case deliveryTime     = "delivery_time"
        case storeSchedule    = "store_schedule"
    }

    // MARK: - Safe Defaults Initializer
    init(
        name: String,
        location: String,
        cuisineType: [String],
        rating: Double = 0,
        reviewCount: Int = 0,
        bannerURL: String? = nil,
        searchURL: String? = nil,
        menuDataURL: String? = nil,
        deliveryTime: String? = nil,
        storeSchedule: [String: DailySchedule]? = nil
    ) {
        self.name = name
        self.location = location
        self.cuisineType = cuisineType
        self.rating = rating
        self.reviewCount = reviewCount
        self.bannerURL = bannerURL
        self.searchURL = searchURL
        self.menuDataURL = menuDataURL
        self.deliveryTime = deliveryTime
        self.storeSchedule = storeSchedule
    }

    // MARK: - Helper
    var todaySchedule: DailySchedule? {
        guard let schedule = storeSchedule else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "en_US")

        let todayKey = formatter.string(from: Date())
        return schedule[todayKey]
    }
}

// MARK: - Schedule Model
struct DailySchedule: Codable {
    var openTime: String
    var closeTime: String

    enum CodingKeys: String, CodingKey {
        case openTime  = "open_time"
        case closeTime = "close_time"
    }
}
