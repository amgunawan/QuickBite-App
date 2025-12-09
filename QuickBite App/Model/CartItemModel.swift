//
//  CartItemModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation

struct CartItemModel: Identifiable, Codable, Equatable {
    var id = UUID()
    var menuItemId: String 
    // Info Dasar
    let name: String
    let imageName: String // Berisi URL Link
    let basePrice: Double
    let baseOriginalPrice: Double?
    
    let prepTime: Int?
    
    // Info Pilihan User
    var quantity: Int
    var note: String
    
    var selectedOptions: [CartOptionSelection]
    
    // Hitung total harga opsi
    var optionsPrice: Double {
        selectedOptions.reduce(0) { $0 + $1.price }
    }
    
    var currentPrice: Double {
        return basePrice + optionsPrice
    }
    
    var originalPrice: Double {
        return (baseOriginalPrice ?? basePrice) + optionsPrice
    }
    
    var totalPrice: Double {
        return currentPrice * Double(quantity)
    }
    
    var optionsDescription: String {
        // Gabungkan semua nama pilihan menjadi satu string
        var desc = selectedOptions.map { $0.choiceName }.joined(separator: ", ")
        
        if !note.isEmpty {
            if !desc.isEmpty { desc += "\n" }
            desc += "Note: \(note)"
        }
        return desc
    }
}

struct CartOptionSelection: Codable, Equatable {
    var categoryName: String
    var choiceName: String
    var price: Double
}
