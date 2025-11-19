//
//  RestaurantDetailView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

// ==================================================================
// --- VIEW (UI Only) ---
// ==================================================================

struct RestaurantDetailView: View {
    
    let imageName: String
    let name: String
    let categories: String
    let rating: Double
    let reviewCount: Int
    let pickupTime: String
    
    @State private var selectedItemForOptions: MenuItemData?
    
    @State private var showingCart = false
    
    @StateObject private var cart = CartViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    HeaderView(imageName: imageName).padding(.bottom)
                    InfoView(name: name, categories: categories, rating: rating, reviewCount: reviewCount, pickupTime: pickupTime)
                        .padding(.horizontal)
                    
                    // --- LIST MENU ---
                    Section(header: CategoryHeaderView(title: "Shirokara Ramen")) {
                        // Item 1
                        let item1 = MenuItemData(
                            id: "katsu_ramen",
                            imageName: "ChickenKatsuShirokaraRamen",
                            name: "Chicken Katsu Shirokara Ramen",
                            salesDescription: "10 terjual",
                            price: 30000,
                            originalPrice: 35000,
                            longDescription: "Ramen noodle, chicken katsu, tamago, kizaminori, negi, narutomaki, with shirokara soupa."
                        )
                        MenuRowLink(item: item1, onAdd: { self.selectedItemForOptions = item1 })
                        
                        // Item 2
                        let item2 = MenuItemData(
                            id: "teriyaki_ramen",
                            imageName: "ChickenTeriyakiShirokaraRamen",
                            name: "Chicken Teriyaki Shirokara Ramen",
                            salesDescription: "5 terjual",
                            price: 35000,
                            originalPrice: nil,
                            longDescription: "Ramen noodle, chicken teriyaki, tamago, kizaminori, negi, narutomaki, with shirokara soupa."
                        )
                        MenuRowLink(item: item2, onAdd: { self.selectedItemForOptions = item2 })
                        
                    }
                    
                    Section(header: CategoryHeaderView(title: "Donburi")) {
                        // Item 3
                        let item3 = MenuItemData(
                            id: "teriyaki_donburi",
                            imageName: "ChickenTeriyakiDonburi",
                            name: "Chicken Teriyaki donburi",
                            salesDescription: "10 terjual",
                            price: 42500,
                            originalPrice: nil,
                            longDescription: "Nasi pulen dengan ayam teriyaki, telur mata sapi, dan taburan wijen."
                        )
                        MenuRowLink(item: item3, onAdd: { self.selectedItemForOptions = item3 })
                        
                        // Item 4
                        let item4 = MenuItemData(
                            id: "katsu_curry",
                            imageName: "ChickenKatsuCurryRice",
                            name: "Chicken Katsu Curry Rice",
                            salesDescription: "10 terjual",
                            price: 42500,
                            originalPrice: nil,
                            longDescription: "Kari khas Jepang yang kental disajikan dengan nasi dan chicken katsu renyah."
                        )
                        MenuRowLink(item: item4, onAdd: { self.selectedItemForOptions = item4 })
                                                
                         // Item 5
                         let item5 = MenuItemData(
                             id: "katsutama_donburi",
                             imageName: "KatsutamaDonburi",
                             name: "Katsutama Donburi",
                             salesDescription: "8 terjual",
                             price: 42500,
                             originalPrice: nil,
                             longDescription: "Chicken katsu yang dimasak dengan telur dan saus donburi spesial di atas nasi hangat."
                         )
                         MenuRowLink(item: item5, onAdd: { self.selectedItemForOptions = item5 })
                        

                        // Item 6
                        let item6 = MenuItemData(
                            id: "katsu_donburi",
                            imageName: "ChickenKatsuDonburi",
                            name: "Chicken Katsu Donburi",
                            salesDescription: "5 terjual",
                            price: 42500,
                            originalPrice: nil,
                            longDescription: "Chicken katsu yang dimasak dengan telur dan saus donburi spesial di atas nasi hangat."
                        )
                        MenuRowLink(item: item6, onAdd: { self.selectedItemForOptions = item6 })
                    }
                }
                .padding(.bottom, cart.items.isEmpty ? 0 : 80)
            }
            
            // Checkout Bar
            if !cart.items.isEmpty {
                CheckoutBarView(showCart: $showingCart)
            }
        }
        .environmentObject(cart)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItemForOptions) { item in
            MenuOptionsView(
                imageName: item.imageName,
                name: item.name,
                salesDescription: item.salesDescription,
                price: item.price,
                originalPrice: item.originalPrice
            )
            .environmentObject(cart)
        }
        .sheet(isPresented: $showingCart) {
            CartListView()
                .environmentObject(cart)
        }
    }
}

// --- Helper View ---
struct MenuRowLink: View {
    let item: MenuItemData
    let onAdd: () -> Void
    @EnvironmentObject var cart: CartViewModel
    
    var body: some View {
        NavigationLink(destination: MenuDetailView(
            imageName: item.imageName,
            name: item.name,
            longDescription: item.longDescription,
            salesDescription: item.salesDescription,
            price: item.price,
            originalPrice: item.originalPrice
        ).environmentObject(cart)) {
            MenuItemRow(
                imageName: item.imageName,
                name: item.name,
                description: item.salesDescription,
                price: item.price,
                originalPrice: item.originalPrice,
                onAdd: onAdd
            )
            .padding(.horizontal).padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

// ==================================================================
// --- SUB-VIEWS (Components) ---
// ==================================================================

struct CheckoutBarView: View {
    @EnvironmentObject var cart: CartViewModel
    
    // DIPERBARUI: Binding untuk membuka cart
    @Binding var showCart: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            

            Button(action: {
                showCart = true
            }) {
                HStack(spacing: 16) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                            .padding(.trailing, 2)
                        
                        // Badge Count
                        if cart.totalItemCount > 0 {
                            Text("\(cart.totalItemCount)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                    .frame(width: 44, height: 44)
                    
                    Spacer()
                    // Info Harga
                    VStack(alignment: .trailing, spacing: 2) {
                        if cart.totalOriginalPrice > cart.totalPrice {
                            Text("Rp\(formatPrice(cart.totalOriginalPrice))")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                        Text("Rp\(formatPrice(cart.totalPrice))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
            }
            .buttonStyle(.plain)
            
            
            
            // Tombol Checkout
            Button(action: { print("Navigasi ke halaman Checkout") }) {
                Text("Checkout")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
    }
}


struct HeaderView: View {
    let imageName: String
    var body: some View { Image(imageName).resizable().scaledToFill().frame(height: 220).clipped() }
}

struct InfoView: View {
    let name: String, categories: String, rating: Double, reviewCount: Int, pickupTime: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name).font(.system(size: 28, weight: .bold))
                    Text(categories).font(.body).foregroundColor(.gray)
                }
                Spacer()
                GroupOrderButton().padding(.top, 4)
            }
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text(String(format: "%.1f", rating)).font(.system(size: 15, weight: .semibold))
                Text("(\(reviewCount) penilaian)").font(.system(size: 15)).foregroundColor(.gray)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
            .padding(.top, 4)
            HStack {
                Image(systemName: "clock").foregroundColor(.orange)
                Text("Pick up in \(pickupTime)").font(.system(size: 15, weight: .semibold)).foregroundColor(.orange)
                Spacer()
                Text("Details >").font(.system(size: 15)).foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
    }
}
struct GroupOrderButton: View {
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                Text("Group Order").font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Color.white).foregroundColor(.orange).cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange, lineWidth: 1.5))
        }
    }
}
struct CategoryHeaderView: View {
    let title: String
    var body: some View {
        Rectangle().fill(Color.orange.opacity(0.3)).frame(height: 8).padding(.vertical, 16)
        ZStack(alignment: .leading) {
            Color.white.frame(height: 25)
            Text(title).font(.system(size: 15).weight(.medium)).padding(.horizontal).foregroundColor(.secondary)
        }
    }
}

struct MenuItemRow: View {
    let imageName: String
    let name: String
    let description: String
    let price: Double
    let originalPrice: Double?
    let onAdd: () -> Void
    
    // Akses Cart untuk cek quantity
    @EnvironmentObject var cart: CartViewModel
    
    // Hitung jumlah item ini di keranjang (berdasarkan nama)
    var quantity: Int {
        cart.items.filter { $0.name == name }.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(imageName).resizable().scaledToFill().frame(width: 90, height: 90).background(Color(.systemGray6)).cornerRadius(8)
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.system(size: 15, weight: .semibold)).lineLimit(2)
                Text(description).font(.system(size: 12)).foregroundColor(.gray)
                Spacer()
                HStack(alignment: .bottom, spacing: 4) {
                    Text("Rp\(formatPrice(price))").font(.system(size: 15, weight: .bold)).foregroundColor(.orange)
                    if let originalPrice = originalPrice {
                        Text("Rp\(formatPrice(originalPrice))").font(.system(size: 12)).foregroundColor(.gray).strikethrough()
                    }
                }
            }
            Spacer()
            
            VStack {
                Spacer()
                
                // LOGIKA TOMBOL BERUBAH DI SINI
                if quantity > 0 {
                    // Tampilkan Stepper jika sudah ada di cart
                    HStack(spacing: 8) {
                        Button(action: {
                            // Kurangi item (hapus varian terakhir yang ditambahkan)
                            if let index = cart.items.lastIndex(where: { $0.name == name }) {
                                cart.decrementItem(id: cart.items[index].id)
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                        }
                        
                        Text("\(quantity)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(minWidth: 16)
                        
                        Button(action: onAdd) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                } else {
                    // Tampilkan Tombol Plus biasa jika belum ada
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
}

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
