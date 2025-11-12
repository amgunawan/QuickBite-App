//
//  MenuDetailView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

// ==================================================================
// --- 1. MAIN VIEW (Halaman Detail Menu) ---
// ==================================================================

struct MenuDetailView: View {
    
    // Properti untuk menerima data
    let imageName: String
    let name: String
    let longDescription: String
    let salesDescription: String
    let price: String
    let originalPrice: String?
    
    // State untuk memunculkan sheet
    @State private var showingOptionsSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. Gambar Header
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .clipped()
                
                // --- Konten Teks ---
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Nama
                    Text(name)
                        .font(.system(size: 22, weight: .bold))
                        .lineLimit(2)
                    
                    // Deskripsi Panjang
                    Text(longDescription)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    // Deskripsi Penjualan
                    Text(salesDescription)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    
                    // --- Harga dan Tombol Tambah ---
                    HStack(alignment: .bottom) {
                        // Harga
                        HStack(spacing: 8) {
                            Text(price)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.orange)
                            
                            if let originalPrice = originalPrice {
                                Text(originalPrice)
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
        
        // Tambahkan .sheet modifier di sini
        .sheet(isPresented: $showingOptionsSheet) {
            MenuOptionsView(
                imageName: self.imageName,
                name: self.name,
                salesDescription: self.salesDescription,
                priceString: self.price,
                originalPriceString: self.originalPrice
            )
        }
    }
}

// ==================================================================
// --- 2. PREVIEW ---
// ==================================================================
struct MenuDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MenuDetailView(
                imageName: "ChickenKatsuShirokaraRamen",
                name: "Chicken Katsu Shirokara Ramen",
                longDescription: "Ramen noodle, chicken katsu, tamago, kizaminori, negi, narutomaki, with shirokara soupa.",
                salesDescription: "10 terjual",
                price: "Rp30.000",
                originalPrice: "Rp35.000"
            )
        }
    }
}
