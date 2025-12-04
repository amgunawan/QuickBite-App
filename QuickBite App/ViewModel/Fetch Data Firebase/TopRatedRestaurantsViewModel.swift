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
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    init() {
        fetchTopRated()
    }
    
    func fetchTopRated() {
        self.isLoading = true
        
        // Query: Ambil semua toko
        // (Tips: Sebaiknya sorting dilakukan di Query Firestore .order(by: "rating", descending: true))
        db.collection("stores").getDocuments { [weak self] snapshot, error in
            
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching top rated:", error.localizedDescription)
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.isLoading = false
                return
            }
            
            // PERBAIKAN UTAMA: Pakai Codable
            // Ini otomatis mengambil menu_data_url tanpa perlu kamu ketik manual
            var results = documents.compactMap { doc -> Restaurant? in
                return try? doc.data(as: Restaurant.self)
            }
            
            // Sorting Manual (Rating Tinggi ke Rendah)
            results.sort { $0.rating > $1.rating }
            
            // Ambil 5 teratas saja
            let top5 = Array(results.prefix(5))
            
            self.topRestaurants = top5
            
            // Convert gambar
            self.convertAllGSURLs()
            self.isLoading = false
        }
    }
    
    // GS URL Converter (Versi Aman dengan Safety Check)
    private func convertAllGSURLs() {
        for (index, restaurant) in topRestaurants.enumerated() {
            
            // 1. Convert Banner URL
            if let gsURL = restaurant.bannerURL, gsURL.starts(with: "gs://") {
                let ref = storage.reference(forURL: gsURL)
                ref.downloadURL { [weak self] url, _ in
                    guard let self = self else { return }
                    if let downloadURL = url {
                        DispatchQueue.main.async {
                            // Cek index supaya tidak crash
                            if self.topRestaurants.indices.contains(index) {
                                // Cek ID biar tidak salah update
                                if self.topRestaurants[index].id == restaurant.id {
                                    self.topRestaurants[index].bannerURL = downloadURL.absoluteString
                                }
                            }
                        }
                    }
                }
            }
            
            // 2. Convert Search URL
            if let gsSearchURL = restaurant.searchURL, gsSearchURL.starts(with: "gs://") {
                let ref = storage.reference(forURL: gsSearchURL)
                ref.downloadURL { [weak self] url, _ in
                    guard let self = self else { return }
                    if let downloadURL = url {
                        DispatchQueue.main.async {
                            if self.topRestaurants.indices.contains(index) {
                                if self.topRestaurants[index].id == restaurant.id {
                                    self.topRestaurants[index].searchURL = downloadURL.absoluteString
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
