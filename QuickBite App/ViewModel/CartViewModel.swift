//
//  CartViewModel.swift
//  QuickBite
//
//  Created by student on 19/11/25.
//

import SwiftUI
import Combine
import Foundation

// ==================================================================
// --- MODEL (Data Structures) ---
// ==================================================================

// 1. Struct untuk Cart Items
struct CartItem: Identifiable {
    var id = UUID()
    let name: String
    let imageName: String
    
    // Prices
    let basePrice: Double
    let baseOriginalPrice: Double?
    let optionsPrice: Double
    
    var noodleType: String
    var level: String
    var topping: String
    var note: String
    
    // DIPERBARUI: quantity jadi 'var' agar bisa diedit
    var quantity: Int
    
    // Logic for Total Price per row
    var currentPrice: Double {
        (basePrice + optionsPrice) * Double(quantity)
    }
    
    var originalPrice: Double {
        ((baseOriginalPrice ?? basePrice) + optionsPrice) * Double(quantity)
    }
    
    var optionsDescription: String {
            var desc = "\(noodleType), \(level), \(topping)"
            if !note.isEmpty {
                desc += "\nNote: \(note)"
            }
            return desc
        }
}

// 2. Struct Helper for Menu Data
struct MenuItemData: Identifiable {
    let id: String
    let imageName: String
    let name: String
    let salesDescription: String
    let price: Double
    let originalPrice: Double?
    let longDescription: String
}

// ==================================================================
// --- VIEW MODEL (Logic & State) ---
// ==================================================================

final class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.currentPrice }
    }
    
    var totalOriginalPrice: Double {
        items.reduce(0) { $0 + $1.originalPrice }
    }
    
    func add(item: CartItem) {
            // Cek duplikasi item yang sama persis
            if let index = items.firstIndex(where: {
                $0.name == item.name &&
                $0.noodleType == item.noodleType &&
                $0.level == item.level &&
                $0.topping == item.topping &&
                $0.note == item.note
            }) {
                items[index].quantity += item.quantity
            } else {
                items.append(item)
            }
        }
    
    func updateItem(_ updatedItem: CartItem) {
            if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
                items[index] = updatedItem
            }
        }
    
    // Fungsi baru untuk mengubah quantity di dalam cart
    func incrementItem(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].quantity += 1
        }
    }
    
    func decrementItem(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                // Opsi: Hapus item jika quantity jadi 0?
                // Untuk sekarang kita biarkan min 1 atau hapus manual
                 items.remove(at: index)
            }
        }
    }
    
    func clearCart() {
        items.removeAll()
    }
}
