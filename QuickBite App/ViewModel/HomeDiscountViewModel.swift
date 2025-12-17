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

// We remove 'struct MenuJSONItem' because we now use 'MenuItem' from MenuModels.swift

// The Display Model for Home View
struct DiscountDisplayItem: Identifiable {
    var id: String
    var discountAmount: Int
    var originalPrice: Double
    var finalPrice: Double
    var itemName: String
    var storeName: String
    var imageURL: String
    var storeId: String
    var menuItem: MenuItem
    var menuDataURL: String
}

@MainActor
class HomeDiscountViewModel: ObservableObject {
    @Published var discountDeals: [DiscountDisplayItem] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // ✅ Cache now stores [MenuItem] instead of [MenuJSONItem]
    private var menuCache: [String: [MenuItem]] = [:]
    
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
                group.leave()
                continue
            }
            
            // Fix path if it's missing "stores/" prefix
            var cleanPath = rawStorePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !cleanPath.contains("/") {
                cleanPath = "stores/\(cleanPath)"
            }
            
            db.document(cleanPath).getDocument { storeSnap, error in
                if let error = error {
                    print("❌ [DEBUG] Failed to fetch store: \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                guard let storeData = storeSnap?.data(),
                      let storeName = storeData["name"] as? String else {
                    group.leave()
                    return
                }
                
                // Priority: Check Store First, then Discount
                let rawMenuURL = (storeData["menu_data_url"] as? String) ?? discountMenuURL
                
                guard let menuURLString = rawMenuURL else {
                    group.leave()
                    return
                }
                
                let cleanURL = menuURLString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Download JSON (GS or HTTPS)
                self.fetchMenuJSON(url: cleanURL) { menuItems in
                    // ✅ Match using 'itemId' from your MenuItem model
                    if let foundItem = menuItems.first(where: { $0.itemId == targetItemId }) {
                        
                        let originalPrice = Double(foundItem.price)
                        let finalPrice = max(0, originalPrice - Double(amount))
                        
                        let newItem = DiscountDisplayItem(
                            id: discountId,
                            discountAmount: amount,
                            originalPrice: originalPrice,
                            finalPrice: finalPrice,
                            itemName: foundItem.name,
                            storeName: storeName,
                            imageURL: foundItem.imageURL ?? "", // Handle optional URL
                            storeId: rawStorePath,
                            menuItem: foundItem,
                            menuDataURL: menuURLString
                        )
                        
                        lock.lock()
                        tempItems.append(newItem)
                        lock.unlock()
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.discountDeals = tempItems
            self.convertImages()
        }
    }
    
    // ✅ Updated to return [MenuItem]
    private func fetchMenuJSON(url: String, completion: @escaping ([MenuItem]) -> Void) {
        if let cached = menuCache[url] { completion(cached); return }
        
        if url.hasPrefix("gs://") {
            let ref = storage.reference(forURL: url)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                self.handleDataResponse(url: url, data: data, error: error, completion: completion)
            }
        }
        else if let httpURL = URL(string: url), (url.hasPrefix("http") || url.hasPrefix("https")) {
            URLSession.shared.dataTask(with: httpURL) { data, response, error in
                self.handleDataResponse(url: url, data: data, error: error, completion: completion)
            }.resume()
        }
        else {
            completion([])
        }
    }
    
    private func handleDataResponse(url: String, data: Data?, error: Error?, completion: @escaping ([MenuItem]) -> Void) {
        if let _ = error { completion([]); return }
        
        guard let data = data else { completion([]); return }

        do {
            // ✅ Decode directly to [MenuItem] using your model
            let items = try JSONDecoder().decode([MenuItem].self, from: data)
            DispatchQueue.main.async { self.menuCache[url] = items }
            completion(items)
        } catch {
            print("❌ [DEBUG] JSON DECODE ERROR for \(url): \(error)")
            completion([])
        }
    }
    
    private func convertImages() {
        let group = DispatchGroup()
        for index in discountDeals.indices {
            let url = discountDeals[index].imageURL
            if url.hasPrefix("gs://") {
                group.enter()
                storage.reference(forURL: url).downloadURL { url, _ in
                    if let u = url {
                        DispatchQueue.main.async {
                            if index < self.discountDeals.count {
                                self.discountDeals[index].imageURL = u.absoluteString
                                // Update the internal item as well
                                self.discountDeals[index].menuItem.imageURL = u.absoluteString
                            }
                        }
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { self.isLoading = false }
    }
}
