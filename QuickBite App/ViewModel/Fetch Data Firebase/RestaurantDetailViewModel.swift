//
//  RestaurantDetailViewModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Combine

@MainActor
class RestaurantDetailViewModel: ObservableObject {

    // MARK: - STATE
    @Published var menuItems: [MenuItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var discounts: [DiscountModel] = []

    // MARK: - Firebase
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    // Cache to prevent re-downloading if called multiple times
    private var menuCache: [String: [MenuItem]] = [:]

    // -----------------------------------------------------
    // MARK: - 1. FETCH MENU (Using Robust JSON Logic)
    // -----------------------------------------------------

    func fetchMenu(from urlString: String?) {
        guard let urlString = urlString, !urlString.isEmpty else {
            errorMessage = "Link menu kosong."
            return
        }

        isLoading = true
        errorMessage = nil
        
        // Use the robust JSON fetcher (same as Home View)
        fetchMenuJSON(url: urlString) { [weak self] items in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if items.isEmpty {
                    self.errorMessage = "Gagal memuat data menu."
                } else {
                    self.menuItems = items
                    self.convertMenuImages() // Fix image URLs
                    self.objectWillChange.send() // Refresh UI
                }
                self.isLoading = false
            }
        }
    }
    
    // ✅ ROBUST JSON FETCHER (Supports GS:// and HTTPS://)
    private func fetchMenuJSON(url: String, completion: @escaping ([MenuItem]) -> Void) {
        // Check Cache first
        if let cached = menuCache[url] {
            completion(cached)
            return
        }
        
        // 1. Handle Firebase Storage (gs://)
        if url.hasPrefix("gs://") {
            let ref = storage.reference(forURL: url)
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                self.handleDataResponse(url: url, data: data, error: error, completion: completion)
            }
        }
        // 2. Handle Public URL (https://)
        else if let httpURL = URL(string: url), (url.hasPrefix("http") || url.hasPrefix("https")) {
            URLSession.shared.dataTask(with: httpURL) { data, response, error in
                self.handleDataResponse(url: url, data: data, error: error, completion: completion)
            }.resume()
        }
        else {
            print("⚠️ Invalid Menu URL Format: \(url)")
            completion([])
        }
    }
    
    // ✅ DECODER HELPER
    private func handleDataResponse(url: String, data: Data?, error: Error?, completion: @escaping ([MenuItem]) -> Void) {
        if let error = error {
            print("❌ Download Error for \(url): \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard let data = data else {
            completion([])
            return
        }

        do {
            // Decode directly to [MenuItem] using your model
            let items = try JSONDecoder().decode([MenuItem].self, from: data)
            
            // Save to cache
            DispatchQueue.main.async { self.menuCache[url] = items }
            
            completion(items)
        } catch {
            print("❌ JSON Decode Error for \(url): \(error)")
            completion([])
        }
    }

    // -----------------------------------------------------
    // MARK: - 2. IMAGE URL CONVERSION
    // -----------------------------------------------------

    private func convertMenuImages() {
        let group = DispatchGroup()

        for index in menuItems.indices {
            let url = menuItems[index].imageURL ?? ""
            
            // Only convert if it's a gs:// link
            if url.hasPrefix("gs://") {
                group.enter()
                storage.reference(forURL: url).downloadURL { [weak self] url, _ in
                    defer { group.leave() }
                    if let httpsURL = url, let self = self {
                        DispatchQueue.main.async {
                            // Ensure index is still valid
                            if index < self.menuItems.count {
                                self.menuItems[index].imageURL = httpsURL.absoluteString
                            }
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            self.objectWillChange.send() // Ensure UI updates when images are ready
        }
    }

    // -----------------------------------------------------
        // MARK: - FETCH DISCOUNTS (MANUAL MAPPING - FOOLPROOF)
        // -----------------------------------------------------

        func fetchDiscounts(storeID: String) {
            let now = Date()
            let cleanID = storeID.replacingOccurrences(of: "stores/", with: "")
            
            print("🔍 Scanning active discounts for target ID: \(cleanID)")

            // 1. Query only by time (Safest)
            // This grabs ALL active discounts, avoiding strict query errors
            db.collection("discounts")
                .whereField("end_date_time", isGreaterThan: now)
                .getDocuments { [weak self] snapshot, error in
                    guard let self else { return }
                    
                    if let error = error {
                        print("❌ Error reading discounts: \(error.localizedDescription)")
                        return
                    }

                    guard let docs = snapshot?.documents else { return }
                    
                    var matches: [DiscountModel] = []

                    for doc in docs {
                        let data = doc.data()
                        
                        // --- STEP 1: MANUALLY EXTRACT STORE ID ---
                        // This handles BOTH Reference (Orange Icon) and String
                        var docStoreId = ""
                        
                        if let storeRef = data["store_id"] as? DocumentReference {
                            docStoreId = storeRef.documentID
                        } else if let storeString = data["store_id"] as? String {
                            docStoreId = storeString.replacingOccurrences(of: "stores/", with: "")
                        }
                        
                        // --- STEP 2: CHECK MATCH ---
                        if docStoreId == cleanID {
                            
                            // --- STEP 3: MANUAL MAPPING (Bypasses Codable Crashing) ---
                            // We extract fields manually. If a field is missing/wrong, we default safely.
                            
                            let amount = data["discount_amount"] as? Int ?? 0
                            let itemId = data["item_id"] as? String ?? ""
                            
                            // Handle Timestamps
                            let startTimestamp = data["start_date_time"] as? Timestamp
                            let endTimestamp = data["end_date_time"] as? Timestamp
                            let startDate = startTimestamp?.dateValue() ?? Date()
                            let endDate = endTimestamp?.dateValue() ?? Date()
                            
                            // Create Model Manually
                            // (Ensure your DiscountModel init is public or memberwise)
                            let newDiscount = DiscountModel(
                                id: doc.documentID,
                                amount: amount,
                                itemId: itemId,
                                startDateTime: startDate,
                                endDateTime: endDate,
                                storeId: docStoreId // We already cleaned this above
                            )
                            
                            matches.append(newDiscount)
                        }
                    }

                    self.discounts = matches
                    print("✅ Final: Found \(self.discounts.count) discounts for this restaurant.")
                    
                    // Force UI Refresh
                    self.objectWillChange.send()
                }
        }

    // -----------------------------------------------------
    // MARK: - 4. PRICE CALCULATION
    // -----------------------------------------------------

    func getPriceInfo(for item: MenuItem) -> (finalPrice: Double, originalPrice: Double?) {
        let basePrice = Double(item.price)

        // Find match based on item_id in the JSON vs item_id in the Discount Document
        if let activeDiscount = discounts.first(where: {
            return $0.itemId == item.itemId
        }) {
            let discountAmount = Double(activeDiscount.amount)
            let finalPrice = max(0, basePrice - discountAmount)
            return (finalPrice, basePrice)
        }

        return (basePrice, nil)
    }
}

// -----------------------------------------------------
// MARK: - GROUPING EXTENSION
// -----------------------------------------------------

struct MenuSection: Identifiable {
    var id: String { category }
    let category: String
    let items: [MenuItem]
}

extension RestaurantDetailViewModel {
    var groupedMenu: [MenuSection] {
        let grouped = Dictionary(
            grouping: menuItems,
            by: { $0.category ?? "Other" }
        )

        return grouped
            .sorted { $0.key < $1.key }
            .map { key, value in
                MenuSection(category: key, items: value)
            }
    }
}
