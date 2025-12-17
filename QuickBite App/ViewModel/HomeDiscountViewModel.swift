//
//  HomeDiscountViewModel.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine

// 1. MATCHING YOUR JSON EXACTLY
struct MenuJSONItem: Codable {
    let item_id: String
    let name: String
    let price: Int
    let image_url: String
}

// 2. The Display Model for Home View
struct DiscountDisplayItem: Identifiable {
    var id: String
    var discountAmount: Int
    var originalPrice: Double
    var finalPrice: Double
    var itemName: String
    var storeName: String
    var imageURL: String
    var storeId: String
}

@MainActor
class HomeDiscountViewModel: ObservableObject {
    @Published var discountDeals: [DiscountDisplayItem] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var menuCache: [String: [MenuJSONItem]] = [:]
    
    init(fetchNow: Bool = true) {
        if fetchNow {
            fetchDiscounts()
        }
    }

    func fetchDiscounts() {
        self.isLoading = true
        let now = Date()
        
        print("🔍 [DEBUG] Starting fetch for active discounts...")
        
        db.collection("discounts")
            .whereField("end_date_time", isGreaterThan: now)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ [DEBUG] Error reading discounts: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ [DEBUG] No active discounts found.")
                    self.isLoading = false
                    return
                }
                
                print("✅ [DEBUG] Found \(documents.count) discounts. Processing...")
                self.processDiscounts(documents)
            }
    }
    
    private func processDiscounts(_ documents: [QueryDocumentSnapshot]) {
        let group = DispatchGroup()
        var tempItems: [DiscountDisplayItem] = []
        let lock = NSLock()
        
        for doc in documents {
            group.enter()
            
            let data = doc.data()
            let discountId = doc.documentID
            let amount = data["discount_amount"] as? Int ?? 0
            let targetItemId = data["item_id"] as? String ?? ""
            
            // Handle Reference OR String
            var rawStorePath = ""
            if let storeRef = data["store_id"] as? DocumentReference {
                rawStorePath = storeRef.path
            } else if let storeString = data["store_id"] as? String {
                rawStorePath = storeString
            }
            
            let discountMenuURL = data["menu_data_url"] as? String
            
            if rawStorePath.isEmpty {
                print("⚠️ [DEBUG] Discount \(discountId) has invalid store_id!")
                group.leave()
                continue
            }
            
            var cleanPath = rawStorePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            if !cleanPath.contains("/") {
                cleanPath = "stores/\(cleanPath)"
            }
            
            print("🔹 [DEBUG] Processing Path: \(cleanPath)")
            
            db.document(cleanPath).getDocument { storeSnap, error in
                if let error = error {
                    print("❌ [DEBUG] Failed to fetch store \(cleanPath): \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                guard let storeData = storeSnap?.data(),
                      let storeName = storeData["name"] as? String else {
                    print("⚠️ [DEBUG] Store \(cleanPath) missing name.")
                    group.leave()
                    return
                }
                
                // Priority: Check Store First, then Discount
                let rawMenuURL = (storeData["menu_data_url"] as? String) ?? discountMenuURL
                
                guard let menuURLString = rawMenuURL else {
                    print("⚠️ [DEBUG] SKIPPING: Store '\(storeName)' has NO menu URL.")
                    group.leave()
                    return
                }
                
                // ✅ CLEAN URL (Remove spaces)
                let cleanURL = menuURLString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Download JSON (GS or HTTPS)
                self.fetchMenuJSON(url: cleanURL) { menuItems in
                    if let foundItem = menuItems.first(where: { $0.item_id == targetItemId }) {
                        
                        let originalPrice = Double(foundItem.price)
                        let finalPrice = max(0, originalPrice - Double(amount))
                        
                        let newItem = DiscountDisplayItem(
                            id: discountId,
                            discountAmount: amount,
                            originalPrice: originalPrice,
                            finalPrice: finalPrice,
                            itemName: foundItem.name,
                            storeName: storeName,
                            imageURL: foundItem.image_url,
                            storeId: rawStorePath
                        )
                        
                        lock.lock()
                        tempItems.append(newItem)
                        lock.unlock()
                    } else {
                        print("⚠️ [DEBUG] Item '\(targetItemId)' not found in JSON for \(storeName)")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("🏁 [DEBUG] Finished. Total deals: \(tempItems.count)")
            self.discountDeals = tempItems
            self.convertImages()
        }
    }
    
    // ✅ ROBUST DOWNLOADER (GS + HTTPS)
    private func fetchMenuJSON(url: String, completion: @escaping ([MenuJSONItem]) -> Void) {
        // 1. Check Cache
        if let cached = menuCache[url] { completion(cached); return }
        
        // 2. Handle Google Storage (gs://)
        if url.hasPrefix("gs://") {
            let ref = storage.reference(forURL: url)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                self.handleDataResponse(url: url, data: data, error: error, completion: completion)
            }
        }
        // 3. Handle Regular Web Link (https://)
        else if let httpURL = URL(string: url), (url.hasPrefix("http") || url.hasPrefix("https")) {
            print("🌐 [DEBUG] Downloading HTTPS JSON: \(url)")
            URLSession.shared.dataTask(with: httpURL) { data, response, error in
                self.handleDataResponse(url: url, data: data, error: error, completion: completion)
            }.resume()
        }
        else {
            print("❌ [DEBUG] Invalid URL Format: '\(url)'")
            completion([])
        }
    }
    
    // Helper to decode data
    private func handleDataResponse(url: String, data: Data?, error: Error?, completion: @escaping ([MenuJSONItem]) -> Void) {
        if let error = error {
            print("❌ [DEBUG] Download Failed for \(url): \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let data = data else {
            print("❌ [DEBUG] Data is empty for \(url)")
            completion([])
            return
        }

        do {
            let items = try JSONDecoder().decode([MenuJSONItem].self, from: data)
            DispatchQueue.main.async { self.menuCache[url] = items }
            completion(items)
        } catch {
            print("❌ [DEBUG] JSON DECODE ERROR for \(url): \(error)")
            // Try to print string to see what went wrong
            if let str = String(data: data, encoding: .utf8) {
                print("   [DEBUG] Raw Content start: \(str.prefix(100))...")
            }
            completion([])
        }
    }
    
    private func convertImages() {
        let group = DispatchGroup()
        for index in discountDeals.indices {
            let url = discountDeals[index].imageURL
            // Only convert if it's gs:// (https:// works automatically in AsyncImage)
            if url.hasPrefix("gs://") {
                group.enter()
                storage.reference(forURL: url).downloadURL { url, _ in
                    if let u = url {
                        DispatchQueue.main.async {
                            if index < self.discountDeals.count { self.discountDeals[index].imageURL = u.absoluteString }
                        }
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { self.isLoading = false }
    }
}
