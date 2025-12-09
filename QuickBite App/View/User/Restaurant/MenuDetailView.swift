//
//  MenuDetailView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI
import FirebaseStorage

// ==================================================================
// --- 1. MAIN VIEW (Halaman Detail Menu) ---
// ==================================================================

struct MenuDetailView: View {
    @EnvironmentObject var cart: CartViewModel
    
    // Properti untuk menerima data
    let item: MenuItemModel
    let customFinalPrice: Double
    let customOriginalPrice: Double?
    
    // State untuk memunculkan sheet
    @State private var showingOptionsSheet = false
    
    @State private var displayImageURL: URL? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. Gambar Header
                if let url = displayImageURL {
                    // Jika sudah dapat URL HTTPS
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(ProgressView())
                    }
                } else {
                    // Fallback / Loading / Local Asset
                    Image(item.imageURL ?? "placeholder_food") // Ganti dengan nama aset default kamu
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                        .overlay(
                            // Tampilkan loading jika linknya ada tapi belum ter-convert
                            item.imageURL != nil ? ProgressView() : nil
                        )
                }                // --- Konten Teks ---
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Nama
                    Text(item.name)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(2)
                    
                    // Deskripsi Panjang
                    Text(item.description ?? "")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    // Deskripsi Penjualan
                    //                    Text(salesDescription)
                    //                        .font(.system(size: 15))
                    //                        .foregroundColor(.gray)
                    //                        .padding(.top, 4)
                    
                    // --- Harga dan Tombol Tambah ---
                    HStack(alignment: .bottom) {
                        // Harga
                        HStack(spacing: 8) {
                            
                            Text("Rp\(formatPrice(customFinalPrice))")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.orange)
                            
                            // PERBAIKAN: Gunakan customOriginalPrice yang sudah Double optional
                            if let originalPrice = customOriginalPrice {
                                Text("Rp\(formatPrice(originalPrice))")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .strikethrough()
                            }
                        }
                        
                        Spacer()
                        
                        // Aksi tombol ini sekarang memunculkan sheet
                        Button(action: {
                            showingOptionsSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.top, 16)
                    
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {loadImage()}
        .sheet(isPresented: $showingOptionsSheet) {
            
            let finalImageString = displayImageURL?.absoluteString ?? item.imageURL ?? ""
            
            MenuOptionsView(
                restaurantName: cart.restaurantName, // Pass info from Cart
                restaurantId: cart.restaurantId,
                item: item,
                finalPrice: customFinalPrice,
                originalPrice: customOriginalPrice,
                itemToEdit: nil
            )
                        .environmentObject(cart)
        }
    }
    
    func loadImage() {
            guard let urlString = item.imageURL else { return }
            
            // Kasus 1: Sudah HTTPS (Aman)
            if urlString.starts(with: "http") {
                self.displayImageURL = URL(string: urlString)
            }
            // Kasus 2: Masih GS Link (Perlu Convert)
            else if urlString.starts(with: "gs://") {
                let storageRef = Storage.storage().reference(forURL: urlString)
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Gagal load gambar detail: \(error.localizedDescription)")
                    } else if let url = url {
                        DispatchQueue.main.async {
                            self.displayImageURL = url
                        }
                    }
                }
            }
            // Kasus 3: Asset Lokal (Nama file biasa)
            else {
                // Biarkan nil, nanti di-handle oleh `else` di View Body (Image(named:))
            }
        }
}

// ==================================================================
// --- 2. PREVIEW ---
// ==================================================================
struct MenuDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Bikin Dummy Model untuk Preview
        let dummyItem = MenuItemModel(
            id: "1",
            name: "Chicken Katsu Shirokara Ramen",
            description: "Ramen kuah pedas putih dengan ayam katsu renyah.",
            price: 35000,
            category: "Ramen",
            imageURL: "gs://quickbite-app-fb529.firebasestorage.app/Raburi/ShirokaraRamen/ChickenKatsuShirokaraRamen.jpeg"
        )
        
        NavigationStack {
            MenuDetailView(
                item: dummyItem,
                customFinalPrice: 30000,
                customOriginalPrice: 35000
            )
        }
        .environmentObject(CartViewModel())
    }
}
