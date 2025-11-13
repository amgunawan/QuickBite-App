//
//  RestaurantDetailView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

// DIPERBARUI: Struct data sederhana untuk .sheet(item: ...)
struct MenuItemData: Identifiable {
    let id: String
    let imageName: String
    let name: String
    let salesDescription: String
    let price: String
    let originalPrice: String?
    let longDescription: String
    
    // Kita bisa tambahkan data opsi di sini jika mau
    // let options: [OptionGroup]
}

// ==================================================================
// --- MAIN VIEW (Tampilan Utama) ---
// ==================================================================

struct RestaurantDetailView: View {
    
    // Properti untuk menerima data
    let imageName: String
    let name: String
    let categories: String
    let rating: Double
    let reviewCount: Int
    let pickupTime: String
    
    // DIPERBARUI: State untuk memunculkan sheet
    @State private var selectedItemForOptions: MenuItemData?
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                // --- HEADER BANNER ---
                HeaderView(imageName: imageName)
                    .padding(.bottom)

                // --- INFO RESTORAN ---
                InfoView(
                    name: name,
                    categories: categories,
                    rating: rating,
                    reviewCount: reviewCount,
                    pickupTime: pickupTime
                )
                .padding(.horizontal)
                // DIPERBARUI: Menghapus padding bawah dari InfoView
                // agar menempel dengan CategoryHeaderView
                // .padding(.bottom, 24)
                
                // --- DAFTAR MENU (MANUAL) ---
                
                // Kategori 1: Shirokara Ramen
                Section(header: CategoryHeaderView(title: "Shirokara Ramen")) {
                    
                    // DIPERBARUI: Data untuk item 1
                    let item1 = MenuItemData(
                        id: "katsu_ramen",
                        imageName: "ChickenKatsuShirokaraRamen",
                        name: "Chicken Katsu Shirokara Ramen",
                        salesDescription: "10 terjual",
                        price: "Rp30.000",
                        originalPrice: "Rp35.000",
                        longDescription: "Ramen noodle, chicken katsu, tamago, kizaminori, negi, narutomaki, with shirokara soupa."
                    )
                    
                    NavigationLink(destination: MenuDetailView(
                        imageName: item1.imageName,
                        name: item1.name,
                        longDescription: item1.longDescription,
                        salesDescription: item1.salesDescription,
                        price: item1.price,
                        originalPrice: item1.originalPrice
                    )) {
                        // DIPERBARUI: Memanggil MenuItemRow dengan data & aksi onAdd
                        MenuItemRow(
                            imageName: item1.imageName,
                            name: item1.name,
                            description: item1.salesDescription,
                            price: item1.price,
                            originalPrice: item1.originalPrice,
                            onAdd: {
                                self.selectedItemForOptions = item1
                            }
                        )
                        .padding(.horizontal).padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    
                    // DIPERBARUI: Data untuk item 2
                    let item2 = MenuItemData(
                        id: "teriyaki_ramen",
                        imageName: "ChickenTeriyakiShirokaraRamen",
                        name: "Chicken Teriyaki Shirokara Ramen",
                        salesDescription: "5 terjual",
                        price: "Rp35.000",
                        originalPrice: nil,
                        longDescription: "Ramen noodle, chicken teriyaki, tamago, kizaminori, negi, narutomaki, with shirokara soupa."
                    )
                    
                    NavigationLink(destination: MenuDetailView(
                        imageName: item2.imageName,
                        name: item2.name,
                        longDescription: item2.longDescription,
                        salesDescription: item2.salesDescription,
                        price: item2.price,
                        originalPrice: item2.originalPrice
                    )) {
                        // DIPERBARUI: Memanggil MenuItemRow dengan data & aksi onAdd
                        MenuItemRow(
                            imageName: item2.imageName,
                            name: item2.name,
                            description: item2.salesDescription,
                            price: item2.price,
                            originalPrice: item2.originalPrice,
                            onAdd: {
                                self.selectedItemForOptions = item2
                            }
                        )
                        .padding(.horizontal).padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    
                    // DIPERBARUI: Tambahkan Divider di antara item
                    Divider().padding(.leading, 120)
                }
                
                // Kategori 2: Donburi
                Section(header: CategoryHeaderView(title: "Donburi")) {
                    
                    // DIPERBARUI: Data untuk item 3
                    let item3 = MenuItemData(
                        id: "teriyaki_donburi",
                        imageName: "ChickenTeriyakiDonburi",
                        name: "Chicken Teriyaki donburi",
                        salesDescription: "10 terjual",
                        price: "Rp42.500",
                        originalPrice: nil,
                        longDescription: "Nasi pulen dengan ayam teriyaki, telur mata sapi, dan taburan wijen."
                    )
                    
                    NavigationLink(destination: MenuDetailView(
                        imageName: item3.imageName,
                        name: item3.name,
                        longDescription: item3.longDescription,
                        salesDescription: item3.salesDescription,
                        price: item3.price,
                        originalPrice: item3.originalPrice
                    )) {
                        // DIPERBARUI: Memanggil MenuItemRow dengan data & aksi onAdd
                        MenuItemRow(
                            imageName: item3.imageName,
                            name: item3.name,
                            description: item3.salesDescription,
                            price: item3.price,
                            originalPrice: item3.originalPrice,
                            onAdd: {
                                self.selectedItemForOptions = item3
                            }
                        )
                        .padding(.horizontal).padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    
                    Divider().padding(.leading, 120)
                    
                    // DIPERBARUI: Data untuk item 4
                    let item4 = MenuItemData(
                        id: "katsu_curry",
                        imageName: "ChickenKatsuCurryRice",
                        name: "Chicken Katsu Curry Rice",
                        salesDescription: "10 terjual",
                        price: "Rp42.500",
                        originalPrice: nil,
                        longDescription: "Kari khas Jepang yang kental disajikan dengan nasi dan chicken katsu renyah."
                    )

                    NavigationLink(destination: MenuDetailView(
                        imageName: item4.imageName,
                        name: item4.name,
                        longDescription: item4.longDescription,
                        salesDescription: item4.salesDescription,
                        price: item4.price,
                        originalPrice: item4.originalPrice
                    )) {
                        // DIPERBARUI: Memanggil MenuItemRow dengan data & aksi onAdd
                        MenuItemRow(
                            imageName: item4.imageName,
                            name: item4.name,
                            description: item4.salesDescription,
                            price: item4.price,
                            originalPrice: item4.originalPrice,
                            onAdd: {
                                self.selectedItemForOptions = item4
                            }
                        )
                        .padding(.horizontal).padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    
                    Divider().padding(.leading, 120)
                    
                    // DIPERBARUI: Data untuk item 5
                    let item5 = MenuItemData(
                        id: "katsutama_donburi",
                        imageName: "KatsutamaDonburi",
                        name: "Katsutama Donburi",
                        salesDescription: "8 terjual",
                        price: "Rp42.500",
                        originalPrice: nil,
                        longDescription: "Chicken katsu yang dimasak dengan telur dan saus donburi spesial di atas nasi hangat."
                    )
                    
                    NavigationLink(destination: MenuDetailView(
                        imageName: item5.imageName,
                        name: item5.name,
                        longDescription: item5.longDescription,
                        salesDescription: item5.salesDescription,
                        price: item5.price,
                        originalPrice: item5.originalPrice
                    )) {
                        // DIPERBARUI: Memanggil MenuItemRow dengan data & aksi onAdd
                        MenuItemRow(
                            imageName: item5.imageName,
                            name: item5.name,
                            description: item5.salesDescription,
                            price: item5.price,
                            originalPrice: item5.originalPrice,
                            onAdd: {
                                self.selectedItemForOptions = item5
                            }
                        )
                        .padding(.horizontal).padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    
                    Divider().padding(.leading, 120)
                    
                    // DIPERBARUI: Data untuk item 6
                    let item6 = MenuItemData(
                        id: "katsu_donburi",
                        imageName: "ChickenKatsuDonburi", // Pastikan asset ini ada
                        name: "Chicken Katsu Donburi",
                        salesDescription: "5 terjual",
                        price: "Rp42.500",
                        originalPrice: nil,
                        longDescription: "Chicken katsu yang dimasak dengan telur dan saus donburi spesial di atas nasi hangat."
                    )
                    
                    NavigationLink(destination: MenuDetailView(
                        imageName: item6.imageName,
                        name: item6.name,
                        longDescription: item6.longDescription,
                        salesDescription: item6.salesDescription,
                        price: item6.price,
                        originalPrice: item6.originalPrice
                    )) {
                        // DIPERBARUI: Memanggil MenuItemRow dengan data & aksi onAdd
                        MenuItemRow(
                            imageName: item6.imageName,
                            name: item6.name,
                            description: item6.salesDescription,
                            price: item6.price,
                            originalPrice: item6.originalPrice,
                            onAdd: {
                                self.selectedItemForOptions = item6
                            }
                        )
                        .padding(.horizontal).padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        
        // DIPERBARUI: Tambahkan .sheet(item: ...) di sini
        .sheet(item: $selectedItemForOptions) { item in
            // Memanggil MenuOptionsView dengan data dari item yang dipilih
            MenuOptionsView(
                imageName: item.imageName,
                name: item.name,
                salesDescription: item.salesDescription,
                priceString: item.price,
                originalPriceString: item.originalPrice
            )
        }
    }
}

// ==================================================================
// --- 4. SUB-VIEWS ---
// ==================================================================

struct HeaderView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(height: 220)
            .clipped()
    }
}

struct InfoView: View {
    let name: String
    let categories: String
    let rating: Double
    let reviewCount: Int
    let pickupTime: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Baris 1: Name dan Kategori
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 28, weight: .bold))
                    Text(categories)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                GroupOrderButton()
                    .padding(.top, 4)
            }
            
            // Baris 2: Rating (Tidak berubah)
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 15, weight: .semibold))
                Text("(\(reviewCount) penilaian)")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
            
            // Baris 3: Waktu Pickup (Tidak berubah)
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                Text("Pick up in \(pickupTime)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.orange)
                Spacer()
                Text("Details >")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
            
        }
    }
}

struct GroupOrderButton: View {
    var body: some View {
        Button(action: {
            print("Group Order tapped")
        }) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                Text("Group Order")
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .foregroundColor(.orange)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange, lineWidth: 1.5)
            )
        }
    }
}

struct CategoryHeaderView: View {
    let title: String
    
    var body: some View {
        // Garis pemisah kuning
        Rectangle()
            .fill(Color.orange.opacity(0.3))
            .frame(height: 8)
            .padding(.vertical, 16)
        
        ZStack(alignment: .leading) {
            Color.white
                .frame(height: 25)
            
            Text(title)
                .font(.system(size: 15).weight(.medium))
                .padding(.horizontal)
                .foregroundColor(.secondary)
        }
    }
}

// DIPERBARUI: MenuItemRow sekarang punya `onAdd`
struct MenuItemRow: View {
    let imageName: String
    let name: String
    let description: String
    let price: String
    let originalPrice: String?
    
    // DIPERBARUI: Aksi untuk tombol "+"
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(price)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.orange)
                    
                    if let originalPrice = originalPrice {
                        Text(originalPrice)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                }
            }
            
            Spacer()
            
            VStack {
                Spacer()
                
                // DIPERBARUI: Aksi tombol sekarang memanggil closure `onAdd`
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding(5)
                        .background(Color.orange)
                        .clipShape(Rectangle())
                        .cornerRadius(4)
                }
            }
        }
    }
}


// ==================================================================
// --- 5. PREVIEW ---
// ==================================================================

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RestaurantDetailView(
                imageName: "Raburi",
                name: "Raburi",
                categories: "Noodles, Japanese",
                rating: 4.7,
                reviewCount: 65,
                pickupTime: "10-20 minutes"
            )
        }
    }
}
