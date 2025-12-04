//
//  TenantStoreModel.swift
//  QuickBite
//
//  Created by student on 03/12/25.
//

import Foundation
import FirebaseFirestore

struct TenantStoreModel: Identifiable, Codable {
    // ID Dokumen (misal: "RABURI")
    @DocumentID var id: String?
    
    // --- Data Profil Dasar ---
    var name: String
    var location: String
    var rating: Double
    var reviewCount: Int
    var cuisineType: [String]
    
    // --- Data Gambar (Link gs:// atau https://) ---
    var bannerURL: String?
    var searchURL: String?
    
    // --- Data Menu (Link ke JSON) ---
    var menuDataURL: String?
    
    // ==========================================
    // DATA KHUSUS TENANT (PRIVASI TINGGI)
    // Bagian ini tidak ada di model User biasa
    // ==========================================
    
    var totalRevenue: Int          // Penting: Pendapatan resto
    var payoutDetails: PayoutDetails? // Penting: Rekening bank
    var storeSchedule: StoreSchedule? // Penting: Jam operasional
    
    // --- Mapping Key (Firebase snake_case -> Swift camelCase) ---
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case rating
        case reviewCount = "review_count"
        case cuisineType = "cuisine_type"
        case bannerURL = "banner_url"
        case searchURL = "search_url"
        case menuDataURL = "menu_data_url"
        
        // Mapping Field Khusus Tenant
        case totalRevenue = "total_revenue"
        case payoutDetails = "payout_details"
        case storeSchedule = "store_schedule"
    }
}

// MARK: - Sub-Models (Struct Pendukung)

// 1. Model untuk Detail Pencairan Dana (Payout)
struct PayoutDetails: Codable {
    var bankName: String
    var accountNumber: String
    var accountHolder: String
    var nmid: String
    
    enum CodingKeys: String, CodingKey {
        case bankName = "bank_name"
        case accountNumber = "account_number"
        case accountHolder = "account_holder"
        case nmid
    }
}

// 2. Model untuk Jadwal (Schedule)
// Karena key di JSON kamu pakai nama hari ("Monday", "Tuesday"), kita sesuaikan di sini.
struct StoreSchedule: Codable {
    var monday: DaySchedule?
    var tuesday: DaySchedule?
    var wednesday: DaySchedule?
    var thursday: DaySchedule?
    var friday: DaySchedule?
    var saturday: DaySchedule?
    var sunday: DaySchedule?
    
    // Perhatikan: Key di JSON diawali Huruf Besar ("Monday"),
    // tapi variable Swift biasanya huruf kecil. Kita mapping di sini.
    enum CodingKeys: String, CodingKey {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
}

// 3. Model untuk Jam Buka/Tutup per Hari
struct DaySchedule: Codable {
    var openTime: String
    var closeTime: String
    
    enum CodingKeys: String, CodingKey {
        case openTime = "open_time"
        case closeTime = "close_time"
    }
}
