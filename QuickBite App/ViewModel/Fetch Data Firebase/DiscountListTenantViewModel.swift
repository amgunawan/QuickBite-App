//
//  DiscountListTenantViewModel.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import Foundation
import FirebaseFirestore
import Combine
import FirebaseStorage

class DiscountListTenantViewModel: ObservableObject {
    
    @Published var discounts: [DiscountModel] = []
    @Published var isLoading = false
    @Published var menuNameMap: [String: String] = [:] //tambahan
    @Published var isMenuLoaded: Bool = false
    
    private let db = Firestore.firestore()
    
    func loadDiscounts(storeId: String) {
        isLoading = true
        
        db.collection("discounts")
            .whereField("store_id", isEqualTo: storeId)
        //    .order(by: "start_date_time", descending: true)
            .getDocuments { snapshot, error in
                self.isLoading = false
                
                if let docs = snapshot?.documents {
                    self.discounts = docs.compactMap {
                        try? $0.data(as: DiscountModel.self)
                    }
                }
            }
    }
    
    //tambahan
    func loadMenuNames(storeId: String) {
        db.collection("stores")
            .document(storeId)
            .getDocument { snapshot, _ in
                guard
                    let data = snapshot?.data(),
                    let menuURL = data["menu_data_url"] as? String
                else { return }
                
                self.fetchMenuJSON(menuURL)
            }
    }
    //tambahan
    private func fetchMenuJSON(_ menuURL: String) {
        let withoutScheme = menuURL.replacingOccurrences(of: "gs://", with: "")
        let parts = withoutScheme.split(separator: "/", maxSplits: 1)
        guard parts.count == 2 else { return }
        
        let bucket = String(parts[0])
        let path = String(parts[1])
        
        let storage = Storage.storage(url: "gs://\(bucket)")
        let ref = storage.reference(withPath: path)
        
        ref.downloadURL { url, _ in
            guard let url else { return }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                DispatchQueue.main.async {
                    guard let data else { return }
                    
                    if let menus = try? JSONDecoder().decode([MenuItem].self, from: data) {
                        self.menuNameMap = Dictionary(
                            uniqueKeysWithValues: menus.map { ($0.itemId, $0.name) }
                        )
                        self.isMenuLoaded = true
                    }
                }
            }.resume()
        }
    }


}
