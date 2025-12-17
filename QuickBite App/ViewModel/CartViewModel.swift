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
    
    @Published var restaurantName: String = ""
    @Published var restaurantId: String = ""
    
    // MARK: - Computed Properties
    
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0) { result, item in
            // Calculate Total: Price * Quantity
            result + (item.currentPrice * Double(item.quantity))
        }
    }
    
    var totalOriginalPrice: Double {
        items.reduce(0) { result, item in
            // Logic: If item has an originalPrice (discounted), use it.
            // If nil (no discount), use the currentPrice as the original.
            
            // ✅ FIX 1: Safely unwrap the optional price using '??'
            let original = item.baseOriginalPrice ?? item.currentPrice
            
            return result + (original * Double(item.quantity))
        }
    }
    
    var averagePrepTime: Int {
        let totalItems = totalItemCount
        guard totalItems > 0 else { return 0 }
        
        // Sum (PrepTime * Quantity)
        let totalMinutes = items.reduce(0) { result, item in
            
            // ✅ FIX 2: Unwrapping the optional 'prepTime' with a default
            let itemPrep = item.prepTime ?? 15
            
            return result + (itemPrep * item.quantity)
        }
        
        return totalMinutes / totalItems
    }
    
    // MARK: - Functions
    
    func add(item: CartItemModel, restaurantName: String, restaurantId: String) {
        
        // 1. Clean IDs to ensure fair comparison (remove spaces/newlines)
        let currentStoreId = self.restaurantId.trimmingCharacters(in: .whitespacesAndNewlines)
        let newStoreId = restaurantId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // DEBUG PRINT: Check your console to see what IDs are being compared!
        print("🛒 Attempting Add: Current Store ['\(currentStoreId)'] vs New Store ['\(newStoreId)']")
        
        // 2. Logic Reset: If cart has items AND IDs are different, Clear it.
        if !items.isEmpty {
            // If the new ID is different, OR if the new ID is valid but the current one was somehow empty
            if currentStoreId != newStoreId {
                print("⚠️ Different restaurant detected! Clearing previous cart.")
                clearCart()
            }
        }
        
        // 3. Save New Store Info
        // (We set this AFTER clearing so the new cart belongs to the new store)
        self.restaurantName = restaurantName
        self.restaurantId = newStoreId
        
        // 4. Add item logic
        if let index = items.firstIndex(where: { isSameItem($0, item) }) {
            print("➕ Updating quantity for existing item")
            items[index].quantity += item.quantity
        } else {
            print("➕ Appending new item")
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
        
        // Optional: If cart is empty, clear restaurant info
        if items.isEmpty {
            print("🗑 Cart is empty, resetting store info.")
            restaurantName = ""
            restaurantId = ""
        }
    }
    
    func clearCart() {
        items.removeAll()
        restaurantName = ""
        restaurantId = ""
    }
    
    private func isSameItem(_ item1: CartItemModel, _ item2: CartItemModel) -> Bool {
        return item1.menuItemId == item2.menuItemId &&
               item1.note == item2.note &&
               item1.selectedOptions == item2.selectedOptions
    }
}
