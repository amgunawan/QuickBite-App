//
//  CartItemModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation

struct CartItemModel: Identifiable, Codable, Equatable {
    var id = UUID()
    
    // Info Dasar (Disalin dari Menu)
    let name: String
    let imageName: String // Berisi URL Link
    let basePrice: Double
    let baseOriginalPrice: Double?
    
    // Info Pilihan User
    var quantity: Int
    var note: String
    
    // Info Opsi Tambahan
    var noodleType: String
    var level: String
    var topping: String
    var optionsPrice: Double // Total harga tambahan (misal topping + level)
    
    // --- COMPUTED PROPERTIES (Hitungan Otomatis) ---
    
    // Harga satuan saat ini (Base + Opsi)
    var currentPrice: Double {
        return basePrice + optionsPrice
    }
    
    // Harga coret satuan (Base Coret + Opsi)
    var originalPrice: Double {
        return (baseOriginalPrice ?? basePrice) + optionsPrice
    }
    
    // Total harga dikali jumlah (Quantity)
    var totalPrice: Double {
        return currentPrice * Double(quantity)
    }
    
    // Deskripsi singkat untuk ditampilkan di List (misal: "Thick, Lvl 5, Classic")
    var optionsDescription: String {
        return [noodleType, level, topping]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
