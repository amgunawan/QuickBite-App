//
//  RestaurantDetailViewModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Combine

class RestaurantDetailViewModel: ObservableObject {
    @Published var menuItems: [MenuItemModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var discounts: [DiscountModel] = []
    
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
                let decodedItems = try JSONDecoder().decode([MenuItemModel].self, from: data)
                
                DispatchQueue.main.async {
                    // --- 🛡️ PERISAI ANTI CRASH 🛡️ ---
                    // Kita tidak percaya ID dari JSON 100%.
                    // Kita buat ulang arraynya dan paksa ganti ID dengan UUID baru.
                    // Ini menjamin tidak akan ada "Duplicate ID" yang bikin crash.
                    
                    var safeItems: [MenuItemModel] = []
                    
                    for item in decodedItems {
                        var cleanItem = item
                        cleanItem.id = UUID().uuidString // GANTI ID JADI UNIK
                        safeItems.append(cleanItem)
                    }
                    
                    self.menuItems = safeItems
                    
                    // Lanjut konversi gambar...
                    self.convertMenuImages()
                }
                
            } catch {
                print("Error Decoding JSON: \(error)") // Print error biar tau kenapa
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Format data menu salah."
                }
            }        }
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
    
    func fetchDiscounts(storeID: String) {
            // storeID misal: "l8jFbmSGa7H4li3XR6nm" (ID dokumen tokonya)
            // Atau kalau di firebase tersimpan path "/stores/ID", sesuaikan querynya.
            
            let db = Firestore.firestore()
            
            // Asumsi di firebase field store_id isinya "/stores/ID_TOKO"
            let storePath = "/stores/\(storeID)"
            
            db.collection("discounts")
                .whereField("store_id", isEqualTo: storePath)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let docs = snapshot?.documents {
                        self.discounts = docs.compactMap { try? $0.data(as: DiscountModel.self) }
                        print("Berhasil ambil \(self.discounts.count) diskon")
                    }
                }
        }
        
        // 3. LOGIKA UTAMA: Hitung Harga Final
        func getPriceInfo(for item: MenuItemModel) -> (finalPrice: Double, originalPrice: Double?) {
            let basePrice = Double(item.price)
            
            // Cari diskon untuk item ini yang sedang aktif
            if let activeDiscount = discounts.first(where: { $0.itemId == item.id && $0.isActive }) {
                
                let discountAmount = Double(activeDiscount.amount)
                let finalPrice = max(0, basePrice - discountAmount) // Jangan sampai minus
                
                // Kembalikan: (Harga Diskon, Harga Asli buat dicoret)
                return (finalPrice, basePrice)
            }
            
            // Kalau tidak ada diskon: (Harga Asli, Nil)
            return (basePrice, nil)
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
