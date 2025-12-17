//
//  AddDiscountTenantViewModel.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import Combine

@MainActor
class AddDiscountTenantViewModel: ObservableObject {
    
    // MARK: - Menu Data
    @Published var menus: [MenuItem] = []
    @Published var selectedMenuId: String = ""
    
    // MARK: - Discount Input
    @Published var discountAmount: Int = 0
    @Published var startDateTime: Date = Date()
    @Published var endDateTime: Date = Date()
    
    // MARK: - Loading State
    @Published var isLoadingMenus: Bool = false
    @Published var menuLoadError: String?
    
    private let db = Firestore.firestore()
    
    // MARK: - Helpers
    var selectedMenuName: String {
        menus.first(where: { $0.itemId == selectedMenuId })?.name ?? "-"
    }
    
    // MARK: - Load Menu from menu_data_url
    func loadMenus(storeId: String) {
        isLoadingMenus = true
        menuLoadError = nil
        
        db.collection("stores")
            .document(storeId)
            .getDocument { snapshot, error in
                guard
                    let data = snapshot?.data(),
                    let menuURL = data["menu_data_url"] as? String
                else {
                    self.menuLoadError = "Menu not found"
                    self.isLoadingMenus = false
                    return
                }
                
                self.fetchMenuJSON(menuURL)
            }
    }
    
    private func fetchMenuJSON(_ menuURL: String) {
        // menuURL contoh:
        // gs://quickbite-app-fb529.firebasestorage.app/Raburi/menu.json
        
        guard menuURL.starts(with: "gs://") else {
            self.menuLoadError = "Invalid menu url"
            self.isLoadingMenus = false
            return
        }
        
        // 1️⃣ Buang "gs://"
        let withoutScheme = menuURL.replacingOccurrences(of: "gs://", with: "")
        
        // 2️⃣ Pisahkan bucket dan path
        let components = withoutScheme.split(separator: "/", maxSplits: 1)
        guard components.count == 2 else {
            self.menuLoadError = "Invalid storage path"
            self.isLoadingMenus = false
            return
        }
        
        let bucket = String(components[0])          // quickbite-app-fb529.firebasestorage.app
        let path = String(components[1])             // Raburi/menu.json
        
        // 3️⃣ Pakai bucket + path dengan BENAR
        let storage = Storage.storage(url: "gs://\(bucket)")
        let ref = storage.reference(withPath: path)
        
        ref.downloadURL { url, error in
            guard let url else {
                self.menuLoadError = "Failed to load menu"
                self.isLoadingMenus = false
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                DispatchQueue.main.async {
                    self.isLoadingMenus = false
                    
                    guard let data else {
                        self.menuLoadError = "Invalid menu data"
                        return
                    }
                    
                    do {
                        let decoded = try JSONDecoder().decode([MenuItem].self, from: data)
                        self.menus = decoded
                        self.selectedMenuId = decoded.first?.itemId ?? ""
                    } catch {
                        self.menuLoadError = "Failed to parse menu"
                    }
                }
            }.resume()
        }
    }

    
    // MARK: - Create Discount
    func createDiscount(storeId: String) async {
        let payload: [String: Any] = [
            "discount_amount": discountAmount,
            "item_id": selectedMenuId,
            "start_date_time": Timestamp(date: startDateTime),
            "end_date_time": Timestamp(date: endDateTime),
            "created_at": Timestamp(date: Date()),
            "store_id": storeId
        ]
        
        do {
            try await db.collection("discounts").addDocument(data: payload)
        } catch {
            print("❌ Failed to create discount:", error.localizedDescription)
        }
    }
}


