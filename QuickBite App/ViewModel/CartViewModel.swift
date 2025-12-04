//
//  CartViewModel.swift
//  QuickBite
//
//  Created by student on 19/11/25.
//

import SwiftUI
import Combine
import Foundation

final class CartViewModel: ObservableObject {
    @Published var items: [CartItemModel] = []
    
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var totalOriginalPrice: Double {
        items.reduce(0) { $0 + ($1.originalPrice * Double($1.quantity)) }
    }
    
    // --- FUNGSI ---
    
    func add(item: CartItemModel) {
        if let index = items.firstIndex(where: { isSameItem($0, item) }) {
            items[index].quantity += item.quantity
        } else {
            items.append(item)
        }
    }
    
    func updateItem(_ updatedItem: CartItemModel) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
        }
    }
    
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
                removeItem(id: id)
            }
        }
    }
    
    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }
    
    func clearCart() {
        items.removeAll()
    }
    
    private func isSameItem(_ item1: CartItemModel, _ item2: CartItemModel) -> Bool {
        return item1.name == item2.name &&
               item1.noodleType == item2.noodleType &&
               item1.level == item2.level &&
               item1.topping == item2.topping &&
               item1.note == item2.note
    }
}
