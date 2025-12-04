//
//  RestaurantDetailViewModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation
import FirebaseStorage
import Combine

class RestaurantDetailViewModel: ObservableObject {
    @Published var menuItems: [MenuItemModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Instance Storage
    private let storage = Storage.storage()
    
    func fetchMenu(from gsURL: String?) {
        guard let gsURL = gsURL, !gsURL.isEmpty else {
            self.errorMessage = "Link menu kosong."
            return
        }
        
        self.isLoading = true
        
        // 1. Download File JSON Menu
        let storageRef = storage.reference(forURL: gsURL)
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Gagal download: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                // 2. Decode JSON ke Array Model
                let decodedItems = try JSONDecoder().decode([MenuItemModel].self, from: data)
                
                DispatchQueue.main.async {
                    self.menuItems = decodedItems
                    // 3. LANGSUNG KONVERSI GAMBAR SETELAH DATA MASUK
                    self.convertMenuImages()
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Format JSON salah."
                    print("JSON Error: \(error)")
                }
            }
        }
    }
    
    // --- FUNGSI AJAIB KONVERSI GAMBAR (gs:// -> https://) ---
    private func convertMenuImages() {
        // Kita pakai DispatchGroup untuk tahu kapan SEMUA gambar selesai dikonversi (Opsional, biar rapi)
        let group = DispatchGroup()
        
        for (index, item) in menuItems.enumerated() {
            
            // Cek apakah punya link dan formatnya gs://
            if let gsLink = item.imageURL, gsLink.starts(with: "gs://") {
                group.enter() // Tandai 1 proses mulai
                
                let imageRef = storage.reference(forURL: gsLink)
                
                imageRef.downloadURL { url, error in
                    // Apapun hasilnya, tandai proses selesai
                    defer { group.leave() }
                    
                    if let httpsURL = url {
                        DispatchQueue.main.async {
                            // Cek index valid biar gak crash
                            if self.menuItems.indices.contains(index) {
                                // UPDATE LINK MENJADI HTTPS
                                self.menuItems[index].imageURL = httpsURL.absoluteString
                            }
                        }
                    } else {
                        print("Gagal convert gambar menu: \(item.name)")
                    }
                }
            }
        }
        
        // Saat semua selesai, matikan loading
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
}

struct MenuSection: Identifiable {
    var id: String { category }
    let category: String
    let items: [MenuItemModel]
}

extension RestaurantDetailViewModel {
    var groupedMenu: [MenuSection] {
        // Kelompokkan item berdasarkan kategori
        let grouped = Dictionary(grouping: menuItems, by: { $0.category ?? "Other" })
        
        // Urutkan kategori abjad & petakan ke struct MenuSection
        return grouped.sorted { $0.key < $1.key }
            .map { key, value in
                MenuSection(category: key, items: value)
            }
    }
}
