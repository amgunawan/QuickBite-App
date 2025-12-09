//
//  LowStockItemsViewModel.swift
//  QuickBite
//
//  Created by student on 09/12/25.
//

import Combine
import Foundation
import FirebaseFirestore
import FirebaseStorage

struct LowStockItemModel: Identifiable {
    let id = UUID()
    let itemId: String
    let name: String
    let stockLeft: Int
}

class LowStockItemsViewModel: ObservableObject {
    @Published var lowStockItems: [LowStockItemModel] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func fetchLowStockItems(storeId: String) {
        let storeRef = db.collection("stores").document(storeId)
        
        // Step 1: Fetch store metadata (menu_data_url)
        storeRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch store meta:", error.localizedDescription)
                return
            }
            
            guard let url = snapshot?.get("menu_data_url") as? String else {
                print("❌ No menu_data_url found")
                return
            }
            
            let menuPath = self.normalizeGSURL(url)
            
            // Step 2: Fetch tracking_item array
            let tracking = snapshot?.get("tracking_item") as? [[String: Any]] ?? []
            var lowItems: [(String, Int)] = []
            
            for item in tracking {
                let id = item["item_id"] as? String ?? ""
                let stock = item["current_stock"] as? Int ?? 0
                
                if stock <= 5 {
                    lowItems.append((id, stock))
                }
            }
            
            // Step 3: Load menu.json → menuMap
            self.loadMenuMap(storeId: storeId, storagePath: menuPath) { menuMap in
                
                var result: [LowStockItemModel] = []
                
                for (id, stock) in lowItems {
                    let name = menuMap[id] ?? id
                    result.append(
                        LowStockItemModel(
                            itemId: id,
                            name: name,
                            stockLeft: stock
                        )
                    )
                }
                
                // Sort ascending by stock
                result.sort { $0.stockLeft < $1.stockLeft }
                
                DispatchQueue.main.async {
                    self.lowStockItems = result
                }
            }
        }
    }
    
    
    // MARK: - Convert GS URL → Storage path
    private func normalizeGSURL(_ url: String) -> String {
        if let range = url.range(of: ".app/") {
            return String(url[range.upperBound...])
        }
        return url
    }
    
    
    // MARK: - Load menu.json (shared parser)
    private func loadMenuMap(storeId: String, storagePath: String, completion: @escaping ([String: String]) -> Void) {
        
        // Use existing cache from TopMenuItemsViewModel
        if let cached = TopMenuItemsViewModel.menuCache[storeId] {
            completion(cached)
            return
        }
        
        let ref = storage.reference(withPath: storagePath)
        
        ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
            
            if let error = error {
                print("❌ Failed to download:", error.localizedDescription)
                completion([:])
                return
            }
            
            guard let data = data else { completion([:]); return }
            
            do {
                let arr = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                
                var map: [String: String] = [:]
                
                arr?.forEach { item in
                    if let id = item["item_id"] as? String,
                       let name = item["name"] as? String {
                        map[id] = name
                    }
                }
                
                TopMenuItemsViewModel.menuCache[storeId] = map
                completion(map)
                
            } catch {
                print("❌ JSON decode error:", error.localizedDescription)
                completion([:])
            }
        }
    }
}
