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
    
    private var listener: ListenerRegistration?

    init() {
        listenRestaurants()
    }
    
    /// Realtime Listener
    func listenRestaurants() {
        listener = db.collection("stores")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to stores:", error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var fetchedRestaurants: [Restaurant] = []
                
                for doc in documents {
                    let data = doc.data()
                    
                    let store = Restaurant(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        rating: data["rating"] as? Double ?? 0.0,
                        reviewCount: data["review_count"] as? Int ?? 0,
                        bannerURL: data["banner_url"] as? String, // masih gs://
                        cuisineType: data["cuisine_type"] as? [String] ?? []
                    )
                    
                    fetchedRestaurants.append(store)
                }
                
                // Update state
                DispatchQueue.main.async {
                    self.restaurants = fetchedRestaurants
                    self.convertAllGSURLs()
                }
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
    
    deinit {
        listener?.remove() // matikan listener ketika viewmodel dibuang
    }
}
