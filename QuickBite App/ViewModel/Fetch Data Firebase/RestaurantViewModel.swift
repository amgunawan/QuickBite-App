//
//  RestaurantViewModel.swift
//  QuickBite
//
//  Created by Angela on 28/11/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

class RestaurantsViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    init() {
        fetchRestaurants()
    }
    
    func fetchRestaurants() {
        db.collection("stores").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching stores:", error)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self.restaurants = documents.map { doc in
                let data = doc.data()
                
                return Restaurant(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    rating: data["rating"] as? Double ?? 0.0,
                    reviewCount: data["review_count"] as? Int ?? 0,
                    bannerURL: data["banner_url"] as? String,   // masih GS URL
                    cuisineType: data["cuisine_type"] as? [String] ?? []
                )
            }
            
            // Convert semua gs:// URL → http URL
            self.convertAllGSURLs()
        }
    }
    
    private func convertAllGSURLs() {
        for index in restaurants.indices {
            if let gsURL = restaurants[index].bannerURL,
               gsURL.starts(with: "gs://") {
                
                let ref = storage.reference(forURL: gsURL)
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print("Error converting gsURL:", error)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.restaurants[index].bannerURL = url?.absoluteString
                    }
                }
            }
        }
    }
}
