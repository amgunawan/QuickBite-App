//
//  RestaurantDetailViewModel.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import Foundation
import Combine
import FirebaseFirestore

class RestaurantDetailViewModel: ObservableObject {
    @Published var store: StoreData?
    @Published var menuCategories: [MenuCategoryData] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init(storeId: String) {
        fetchRestaurantData(storeId: storeId)
    }
    
    // Helper to load menu data from the local JSON file
    private func loadMenuFromJSON() -> [MenuItemData]? {
        // IMPORTANT: Ensure 'menu.json' is in your Xcode project's resources
        guard let url = Bundle.main.url(forResource: "menu", withExtension: "json") else {
            print("ERROR: Menu JSON file not found in bundle.")
            self.errorMessage = "Menu data file missing."
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let menuItems = try JSONDecoder().decode([MenuItemData].self, from: data) 
            return menuItems
        } catch {
            print("ERROR decoding menu JSON: \(error)")
            self.errorMessage = "Error parsing menu data: \(error.localizedDescription)"
            return nil
        }
    }
    
    // Fetcher Method
    func fetchRestaurantData(storeId: String) {
        self.isLoading = true
        self.errorMessage = nil
        
        // --- A. Fetch Store Metadata from Firestore ---
        db.collection("stores").document(storeId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load store details: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = document?.data() else {
                DispatchQueue.main.async {
                    self.errorMessage = "Store document not found."
                    self.isLoading = false
                }
                return
            }
            
            // --- B. Manual Parsing of Store Data ---
            let categories = data["cuisine_type"] as? [String] ?? []
            let name = data["name"] as? String ?? "N/A"
            let rating = data["rating"] as? Double ?? 0.0
            let reviewCount = data["review_count"] as? Int ?? 0
            let location = data["location"] as? String ?? ""
            
            // Parsing Schedule
            var scheduleDict: [String: ScheduleData] = [:]
            if let firestoreSchedule = data["store_schedule"] as? [String: [String: String]] {
                for (day, times) in firestoreSchedule {
                    if let open = times["open_time"], let close = times["close_time"] {
                        // ✅ FIX: Now calling ScheduleData with camelCase property names
                        scheduleDict[day] = ScheduleData(openTime: open, closeTime: close) 
                    }
                }
            }

            let fetchedStoreData = StoreData(
                id: storeId,
                name: name,
                rating: rating,
                reviewCount: reviewCount,
                categories: categories,
                location: location,
                storeSchedule: scheduleDict
            )
            
            DispatchQueue.main.async {
                self.store = fetchedStoreData
                self.fetchMenuAndFinishLoading()
            }
        }
    }
    
    // 3. Process Menu Data (Grouping)
    private func fetchMenuAndFinishLoading() {
        guard let menuItems = loadMenuFromJSON() else {
            self.isLoading = false
            return
        }
        
        let groupedItems = Dictionary(grouping: menuItems, by: { $0.category })
        
        let menuCategories: [MenuCategoryData] = groupedItems
            .map { (categoryTitle, itemsArray) in
                MenuCategoryData(title: categoryTitle, items: itemsArray)
            }
            .sorted { $0.title < $1.title }
        
        self.menuCategories = menuCategories
        self.isLoading = false
    }
    
    var pickupTime: String {
        let allItems = self.menuCategories.flatMap { $0.items }
        let maxPrepTime = allItems.map { $0.prepTimeMinutes }.max() ?? 10
        let estimatedTime = maxPrepTime + 10
        return "\(estimatedTime) minutes"
    }
}
