//
//  TenantMenuViewModel.swift
//  QuickBite
//
//  Created by student on 11/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import Combine

class TenantMenuViewModel: ObservableObject {
    
    // MARK: - Published (UI updates)
    @Published var sections: [MenuSectionModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Internal Storage
    private let db = Firestore.firestore()
    let storeId: String                         // made public so EditMenu can read if needed
    @Published var storeFolderName: String?                // derived from menuDataURL
    
    private var menuDataURL: String?            // gs://.../menu.json
    private var allItems: [MenuItem] = []       // flat list
    private var trackingItems: [TrackingItem] = []   // from Firestore tracking_item
    
    private var ordersListener: ListenerRegistration?
    
    // MARK: - Init
    init(storeId: String) {
        self.storeId = storeId
        loadStoreInfo()
        listenToOrders()       // 🔥 start automatic stock deduction
    }
    
    deinit {
        ordersListener?.remove()
    }
    
    // MARK: - LOAD STORE DOCUMENT
    private func loadStoreInfo() {
        isLoading = true
        errorMessage = nil
        
        let storeRef = db.collection("stores").document(storeId)
        
        storeRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.finishError("Failed to fetch store: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                self.finishError("Store not found.")
                return
            }
            
            // menu_data_url
            guard let url = data["menu_data_url"] as? String else {
                self.finishError("menu_data_url missing in Firestore.")
                return
            }
            self.menuDataURL = url
            
            // extract store folder (ex: "Raburi")
            self.storeFolderName = MenuItem.extractStoreFolder(from: url)
            
            // tracking_item array
            if let trackingArray = data["tracking_item"] as? [[String: Any]] {
                do {
                    let jsonData = try JSONSerialization.data(
                        withJSONObject: trackingArray,
                        options: []
                    )
                    self.trackingItems = try JSONDecoder().decode([TrackingItem].self, from: jsonData)
                } catch {
                    print("Error decoding tracking items:", error)
                }
            }
            
            // Load menu JSON after tracking
            self.loadMenuJSON()
        }
    }
    
    // MARK: - LOAD menu.json from Firebase Storage
    private func loadMenuJSON() {
        guard let menuPath = menuDataURL else {
            finishError("menu_data_url is empty.")
            return
        }
        
        let ref = Storage.storage().reference(forURL: menuPath)
        
        ref.getData(maxSize: 7 * 1024 * 1024) { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                self.finishError("Failed to download menu.json: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.finishError("menu.json is empty or unreadable")
                return
            }
            
            do {
                let items = try JSONDecoder().decode([MenuItem].self, from: data)
                self.allItems = items
                self.mergeTrackingAndBuildSections()
            } catch {
                self.finishError("Failed to decode menu.json: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - MERGE tracking_item → currentStock
    private func mergeTrackingAndBuildSections() {
        for index in allItems.indices {
            let id = allItems[index].itemId
            
            if let track = trackingItems.first(where: { $0.itemId == id }) {
                allItems[index].currentStock = track.currentStock
            } else {
                allItems[index].currentStock = allItems[index].defaultStock
            }
        }
        
        buildSectionsUI()
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    // MARK: - BUILD sections for UI
    private func buildSectionsUI() {
        let grouped = Dictionary(grouping: allItems, by: { $0.category })
        
        var result: [MenuSectionModel] = []
        
        for (category, items) in grouped {
            result.append(MenuSectionModel(title: category, items: items))
        }
        
        result.sort { $0.title < $1.title }
        
        DispatchQueue.main.async {
            self.sections = result
        }
    }
    
    // MARK: - PUBLIC: Refresh
    func refresh() {
        loadStoreInfo()
    }
    
    // MARK: - PUBLIC: Update item
    func updateItem(_ updated: MenuItem) {
        // update / append to allItems
        if let idx = allItems.firstIndex(where: { $0.itemId == updated.itemId }) {
            allItems[idx] = updated
        } else {
            allItems.append(updated)
        }
        
        // update / append tracking item
        if let trackIdx = trackingItems.firstIndex(where: { $0.itemId == updated.itemId }) {
            trackingItems[trackIdx].currentStock = updated.currentStock
        } else {
            trackingItems.append(
                TrackingItem(itemId: updated.itemId,
                             currentStock: updated.currentStock,
                             totalSold: 0)
            )
        }
        
        buildSectionsUI()
        saveAllToBackend()
    }
    
    // MARK: ===============================================================
    // MARK: - IMAGE LISTING FOR CATEGORY (Storage)
    // MARK: ===============================================================
    
    func listImages(for category: String, completion: @escaping ([String]) -> Void) {
        guard let storeFolder = storeFolderName else {
            completion([])
            return
        }
        
        let folderPath = "\(storeFolder)/\(category)"
        let ref = Storage.storage().reference().child(folderPath)
        
        ref.listAll { result, error in
            if let error = error {
                print("Error listing images:", error)
                completion([])
                return
            }

            guard let result = result else {
                completion([])
                return
            }

            let filenames = result.items.map { $0.name }
            completion(filenames)
        }
    }

    // MARK: - UPLOAD IMAGE TO FIREBASE STORAGE
    func uploadImage(
        _ data: Data,
        filename: String,
        category: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let storeFolder = storeFolderName else {
            completion(nil)
            return
        }
        
        let path = "\(storeFolder)/\(category)/\(filename)"
        let ref = Storage.storage().reference().child(path)
        
        ref.putData(data, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload failed:", error)
                completion(nil)
                return
            }
            
            // 🔥 RETURN HTTPS DOWNLOAD URL
            ref.downloadURL { url, error in
                if let url = url {
                    completion(url.absoluteString)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // ====================================================================
    // MARK: - 🔥 STOCK DEDUCTION AUTOMATIC (ORDERS LISTENER)
    // ====================================================================
    
    func listenToOrders() {
        let query = db.collection("orders")
            .whereField("store_id", isEqualTo: "/stores/\(storeId)")
        
        ordersListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            guard let docs = snapshot?.documents else { return }
            
            for doc in docs {
                let data = doc.data()
                
                guard let status = data["status"] as? String,
                      status == "completed"
                else { continue }
                
                guard let items = data["items"] as? [[String: Any]] else { continue }
                
                for itemData in items {
                    if let itemId = itemData["item_id"] as? String,
                       let qty = itemData["quantity"] as? Int {
                        self.deductStock(itemId: itemId, qty: qty)
                    }
                }
            }
        }
    }
    
    // MARK: - REDUCE STOCK FUNCTION
    private func deductStock(itemId: String, qty: Int) {
        guard qty > 0 else { return }
        
        // tracking item
        if let idx = trackingItems.firstIndex(where: { $0.itemId == itemId }) {
            trackingItems[idx].currentStock = max(0, trackingItems[idx].currentStock - qty)
        }
        
        // UI item
        if let i = allItems.firstIndex(where: { $0.itemId == itemId }) {
            allItems[i].currentStock = max(0, allItems[i].currentStock - qty)
        }
        
        // refresh UI
        buildSectionsUI()
        
        // save to Firestore only
        saveTrackingItems()
    }
    
    
    // ====================================================================
    // MARK: - SAVE menu.json + tracking_item
    // ====================================================================
    
    private func saveAllToBackend() {
        saveMenuJSON()
        saveTrackingItems()
    }
    
    private func saveMenuJSON() {
        guard let menuPath = menuDataURL else { return }
        
        let ref = Storage.storage().reference(forURL: menuPath)
        
        do {
            let json = try JSONEncoder().encode(allItems)
            ref.putData(json, metadata: nil) { _, error in
                if let error = error {
                    print("Failed to upload menu.json:", error)
                } else {
                    print("menu.json updated")
                }
            }
        } catch {
            print("Failed to encode menu.json:", error)
        }
    }
    
    private func saveTrackingItems() {
        do {
            let json = try JSONEncoder().encode(trackingItems)
            let array = try JSONSerialization.jsonObject(with: json) as? [[String: Any]] ?? []
            
            let ref = db.collection("stores").document(storeId)
            ref.updateData(["tracking_item": array]) { error in
                if let error = error {
                    print("Failed to update tracking_item:", error)
                } else {
                    print("tracking_item updated")
                }
            }
        } catch {
            print("Failed to encode tracking_item:", error)
        }
    }
    
    // MARK: - Error Handler
    private func finishError(_ msg: String) {
        DispatchQueue.main.async {
            self.errorMessage = msg
            self.isLoading = false
        }
    }
    
    @Published var newItemDraft: MenuItem? = nil

    func prepareNewItem(for category: String) {
        newItemDraft = MenuItem(
            itemId: String(UUID().uuidString.prefix(6)),
            name: "",
            description: "",
            price: 0,
            defaultStock: 10,
            prepTimeMinutes: 10,
            category: category,
            imageURL: "",
            options: [],
            currentStock: 0
        )
    }

    func saveNewItem(_ item: MenuItem) {
        allItems.append(item)

        trackingItems.append(
            TrackingItem(itemId: item.itemId,
                         currentStock: item.currentStock,
                         totalSold: 0)
        )
        buildSectionsUI()
        saveAllToBackend()
    }
    
    // MARK: - ADD ITEM
    func addItem(to sectionTitle: String) {
        prepareNewItem(for: sectionTitle)
    }

}

