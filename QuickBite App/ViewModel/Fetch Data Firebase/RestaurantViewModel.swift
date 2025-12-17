//
//  RestaurantsViewModel.swift
//  QuickBite
//
//  Created by Angela on 28/11/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

final class RestaurantsViewModel: ObservableObject {

    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    init() {
        fetchRestaurants()
    }

    // MARK: - Fetch
    func fetchRestaurants() {
        isLoading = true

        db.collection("stores").getDocuments { [weak self] snapshot, error in
            guard let self else { return }

            if let error = error {
                print("❌ Error fetching stores:", error)
                self.isLoading = false
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No store documents found")
                self.isLoading = false
                return
            }

            var decodedRestaurants: [Restaurant] = []

            for doc in documents {
                do {
                    var restaurant = try doc.data(as: Restaurant.self)

                    // ✅ SAFETY DEFAULTS
                    if restaurant.deliveryTime == nil {
                        restaurant.deliveryTime = "<15 min"
                    }

                    decodedRestaurants.append(restaurant)
                } catch {
                    print("❌ Failed decoding store \(doc.documentID): \(error)")
                }
            }

            self.restaurants = decodedRestaurants

            print("✅ Loaded \(decodedRestaurants.count) restaurants")

            // Convert all gs:// URLs
            self.convertAllGSURLs()

            self.isLoading = false
        }
    }

    // MARK: - Image URL Conversion
    private func convertAllGSURLs() {
        for (index, restaurant) in restaurants.enumerated() {

            // Banner
            if let gsBanner = restaurant.bannerURL, gsBanner.hasPrefix("gs://") {
                convert(gsURL: gsBanner, index: index, keyPath: \.bannerURL)
            }

            // Search Icon
            if let gsSearch = restaurant.searchURL, gsSearch.hasPrefix("gs://") {
                convert(gsURL: gsSearch, index: index, keyPath: \.searchURL)
            }
        }
    }

    private func convert(
        gsURL: String,
        index: Int,
        keyPath: WritableKeyPath<Restaurant, String?>
    ) {
        let ref = storage.reference(forURL: gsURL)

        ref.downloadURL { [weak self] url, error in
            guard let self else { return }

            if let error = error {
                print("❌ Failed converting image:", error)
                return
            }

            DispatchQueue.main.async {
                guard self.restaurants.indices.contains(index) else { return }
                self.restaurants[index][keyPath: keyPath] = url?.absoluteString
            }
        }
    }
}

