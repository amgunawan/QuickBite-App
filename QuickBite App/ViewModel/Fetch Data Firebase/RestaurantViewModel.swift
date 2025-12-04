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

class RestaurantsViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false // Tambahan biar UI bisa loading spinner
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    init() {
        fetchRestaurants()
    }
    
    func fetchRestaurants() {
        self.isLoading = true
        
        db.collection("stores").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching stores:", error)
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.isLoading = false
                return
            }
            
            // PERBAIKAN 1: Pakai CompactMap & Codable
            // Ini otomatis mengambil SEMUA field (termasuk menu_data_url)
            // sesuai CodingKeys yang ada di RestaurantModel.swift
            self.restaurants = documents.compactMap { doc -> Restaurant? in
                return try? doc.data(as: Restaurant.self)
            }
            
            // Debugging: Cek apakah link menu sudah masuk
            for resto in self.restaurants {
                print("Resto: \(resto.name), Menu Link: \(resto.menuDataURL ?? "KOSONG")")
            }
            
            // Convert gambar banner dari gs:// ke https://
            self.convertAllGSURLs()
            self.isLoading = false
        }
    }
    
    private func convertAllGSURLs() {
        // PERBAIKAN 2: Enumerated Loop
        // Kita butuh index DAN datanya sekaligus
        for (index, restaurant) in restaurants.enumerated() {
            
            // Cek apakah ada bannerURL dan formatnya gs://
            if let gsURL = restaurant.bannerURL, gsURL.starts(with: "gs://") {
                
                let ref = storage.reference(forURL: gsURL)
                
                ref.downloadURL { [weak self] url, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Gagal convert gambar \(restaurant.name):", error)
                        return
                    }
                    
                    // PERBAIKAN 3: Safety Check (Anti Crash)
                    DispatchQueue.main.async {
                        // Pastikan index masih valid (user tidak refresh mendadak)
                        if self.restaurants.indices.contains(index) {
                            // Update URL gambar
                            self.restaurants[index].bannerURL = url?.absoluteString
                        }
                    }
                }
            }
        }
    }
}
