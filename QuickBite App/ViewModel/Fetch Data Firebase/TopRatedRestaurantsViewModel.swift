//
//  TopRatedRestaurantsViewModel.swift
//  QuickBite App
//
//  Created by Angela on 28/11/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

class TopRatedRestaurantsViewModel: ObservableObject {
    @Published var topRestaurants: [Restaurant] = []
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    func fetchTopRated() {
        db.collection("stores").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching restaurants:", error.localizedDescription)
                return
            }
            
            guard let docs = snapshot?.documents else { return }
            
            // Decode manual (sama seperti RestaurantsViewModel)
            var result: [Restaurant] = []
            
            for doc in docs {
                let data = doc.data()
                
                let restaurant = Restaurant(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    rating: data["rating"] as? Double ?? 0.0,
                    reviewCount: data["review_count"] as? Int ?? 0,
                    bannerURL: data["banner_url"] as? String,   // masih GS URL
                    searchURL: data["search_url"] as? String,
                    cuisineType: data["cuisine_type"] as? [String] ?? []
                )
                
                result.append(restaurant)
            }
            
            // Sort by rating highest → lowest
            let sorted = result.sorted { $0.rating > $1.rating }
            
            DispatchQueue.main.async {
                self.topRestaurants = sorted
                self.convertAllGSURLs()  // SAMAKAN DENGAN RestaurantsViewModel
            }
        }
    }
    
    // GS URL Converter
    private func convertAllGSURLs() {
        for index in topRestaurants.indices {
            
            // Convert bannerURL
            if let gsURL = topRestaurants[index].bannerURL,
               gsURL.starts(with: "gs://") {
                
                let ref = storage.reference(forURL: gsURL)
                ref.downloadURL { url, _ in
                    DispatchQueue.main.async {
                        self.topRestaurants[index].bannerURL = url?.absoluteString
                    }
                }
            }
            
            // Convert searchURL
            if let gsURL = topRestaurants[index].searchURL,
               gsURL.starts(with: "gs://") {
                
                let ref = storage.reference(forURL: gsURL)
                ref.downloadURL { url, _ in
                    DispatchQueue.main.async {
                        self.topRestaurants[index].searchURL = url?.absoluteString
                    }
                }
            }
        }
    }
}
