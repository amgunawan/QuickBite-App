//
//  FoodCategoryViewModel.swift
//  QuickBite
//
//  Created by Angela on 28/11/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

class FoodCategoryViewModel: ObservableObject {
    @Published var stores: [Restaurant] = []
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()

    func fetchStores(by category: String) {
        db.collection("stores")
            .whereField("cuisine_type", arrayContains: category)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error filtering stores:", error.localizedDescription)
                    return
                }
                
                guard let docs = snapshot?.documents else { return }
                
                var result: [Restaurant] = []
                
                for doc in docs {
                    let data = doc.data()
                    
                    let restaurant = Restaurant(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        rating: data["rating"] as? Double ?? 0.0,
                        reviewCount: data["review_count"] as? Int ?? 0,
                        bannerURL: data["banner_url"] as? String,
                        cuisineType: data["cuisine_type"] as? [String] ?? []
                    )
                    
                    result.append(restaurant)
                }
                
                DispatchQueue.main.async {
                    self.stores = result
                    self.convertAllGSURLs()
                }
            }
    }
    
    private func convertAllGSURLs() {
        for index in stores.indices {
            if let gsURL = stores[index].bannerURL,
               gsURL.starts(with: "gs://") {
                
                let ref = storage.reference(forURL: gsURL)
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print("Error converting gsURL:", error.localizedDescription)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.stores[index].bannerURL = url?.absoluteString
                    }
                }
            }
        }
    }
}
