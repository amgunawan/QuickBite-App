//
//  TopMenuItemsViewModel.swift
//  QuickBite
//
//  Created by student on 09/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine

struct MenuItemSoldModel: Identifiable {
    let id = UUID()
    let itemId: String
    let name: String
    let sold: Int
}

class TopMenuItemsViewModel: ObservableObject {
    @Published var topMenuItems: [MenuItemSoldModel] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Cache: storeId → menuMap
    static var menuCache: [String: [String: String]] = [:]
    
    
    func fetchTopMenuItems(storeId: String) {
        fetchStoreMeta(storeId: storeId) { menuPath in
            guard let menuPath = menuPath else {
                print("❌ menu_data_url missing for store:", storeId)
                return
            }
            
            self.fetchSoldItems(storeId: storeId) { soldCount in
                self.loadMenuMap(storeId: storeId, storagePath: menuPath) { menuMap in
                    
                    var result: [MenuItemSoldModel] = soldCount.map { (itemId, qty) in
                        MenuItemSoldModel(
                            itemId: itemId,
                            name: menuMap[itemId] ?? itemId,
                            sold: qty
                        )
                    }
                    
                    result.sort { $0.sold > $1.sold }
                    result = Array(result.prefix(3))
                    
                    DispatchQueue.main.async {
                        self.topMenuItems = result
                    }
                }
            }
        }
    }
    
    
    // MARK: 🔥 STEP 1 — Fetch menu_data_url from Firestore
    private func fetchStoreMeta(storeId: String, completion: @escaping (String?) -> Void) {
        db.collection("stores")
            .document(storeId)
            .getDocument { snapshot, error in
                
                if let error = error {
                    print("❌ Failed to fetch store meta:", error.localizedDescription)
                    completion(nil)
                    return
                }
                
                guard let url = snapshot?.get("menu_data_url") as? String else {
                    completion(nil)
                    return
                }
                
                print("📦 menu_data_url:", url)
                
                // Convert "gs://bucket/folder/menu.json" → "folder/menu.json"
                let path = self.normalizeGSURL(url)
                completion(path)
            }
    }
    
    
    // MARK: 🔥 Convert gs:// URL → Storage path
    private func normalizeGSURL(_ gsURL: String) -> String {
        // Example:
        // gs://quickbite-app.appspot.com/Raburi/menu.json
        // → Raburi/menu.json
        if let range = gsURL.range(of: ".app/") {
            return String(gsURL[range.upperBound...])
        }
        return gsURL
    }
    
    
    // MARK: 🔥 STEP 2 — Count sold items
    private func fetchSoldItems(storeId: String, completion: @escaping ([String: Int]) -> Void) {
        let storeRef = db.collection("stores").document(storeId)
        
        db.collection("orders")
            .whereField("store_id", isEqualTo: storeRef)
            .whereField("status", isEqualTo: "completed")
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Firestore error:", error.localizedDescription)
                    completion([:])
                    return
                }
                
                var sold: [String: Int] = [:]
                
                snapshot?.documents.forEach { doc in
                    if let items = doc.get("items") as? [[String: Any]] {
                        for item in items {
                            if let id = item["item_id"] as? String {
                                let qty = item["quantity"] as? Int ?? 0
                                sold[id, default: 0] += qty
                            }
                        }
                    }
                }
                
                completion(sold)
            }
    }
    
    
    // MARK: 🔥 STEP 3 — Load menu.json with Caching
    private func loadMenuMap(storeId: String, storagePath: String, completion: @escaping ([String: String]) -> Void) {
        
        // Gunakan cache jika ada
        if let cached = Self.menuCache[storeId] {
            print("⚡ Using cached menu.json")
            completion(cached)
            return
        }

        let ref = storage.reference(withPath: storagePath)
        print("📥 Download JSON from:", storagePath)

        ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
            
            if let error = error {
                print("❌ Failed to download:", error.localizedDescription)
                completion([:])
                return
            }
            
            guard let data = data else {
                completion([:])
                return
            }
            
            do {
                let rawString = String(data: data, encoding: .utf8) ?? ""
                print("📝 RAW JSON STRING:\n\(rawString.prefix(300)) ...")

                // JSON kamu adalah ARRAY, bukan Dictionary
                let arr = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]

                var menuMap: [String: String] = [:]
                
                arr?.forEach { item in
                    if let id = item["item_id"] as? String,
                       let name = item["name"] as? String {
                        menuMap[id] = name
                    }
                }

                print("📖 Parsed menu:", menuMap)
                
                // Cache untuk store ini
                Self.menuCache[storeId] = menuMap
                completion(menuMap)

            } catch {
                print("❌ JSON decode error:", error.localizedDescription)
                completion([:])
            }
        }
    }

}




