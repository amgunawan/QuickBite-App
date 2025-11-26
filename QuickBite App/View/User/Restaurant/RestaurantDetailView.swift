//
//  RestaurantDetailView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI
import Kingfisher // <-- Added for KFImage usage

// ==================================================================
// --- VIEW (UI Only) ---
// ==================================================================

struct RestaurantDetailView: View {
   
    @StateObject var viewModel: RestaurantDetailViewModel
   
    // ❌ REMOVED REDUNDANT PROPERTIES:
    // imageName, name, categories, rating, reviewCount, and pickupTime
    // These are now accessed directly via viewModel.store and viewModel.pickupTime.
   
    @State private var selectedItemForOptions: MenuItemData?
   
    @State private var showingCart = false
   
    @StateObject private var cart = CartViewModel()
   
    var body: some View {
        ZStack(alignment: .bottom) {
           
            if viewModel.isLoading {
                ProgressView("Loading Restaurant Details...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let store = viewModel.store {
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        
                        // HeaderView remains the same, assuming store.id is a local asset name for the logo
                        HeaderView(imageName: store.id).padding(.bottom)
                        
                        InfoView(
                            name: store.name,
                            categories: store.categories.joined(separator: ", "),
                            rating: store.rating,
                            reviewCount: store.reviewCount,
                            pickupTime: viewModel.pickupTime // Dynamic pickupTime used here
                        )
                        .padding(.horizontal)
                        
                        // --- LIST MENU: DYNAMICALLY GENERATED ---
                        ForEach(viewModel.menuCategories) { category in
                            Section(header: CategoryHeaderView(title: category.title)) {
                                ForEach(category.items) { item in
                                    MenuRowLink(item: item, onAdd: { self.selectedItemForOptions = item })
                                }
                            }
                        }
                    }
                    .padding(.bottom, cart.items.isEmpty ? 0 : 80)
                }
                
                // Checkout Bar
                if !cart.items.isEmpty {
                    CheckoutBarView(showCart: $showingCart)
                }
            } else {
                Text(viewModel.errorMessage ?? "An unknown error occurred loading the restaurant.")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .environmentObject(cart)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItemForOptions) { item in
            MenuOptionsView(
                // ✅ FIX: Use item.imageUrl for remote loading
                imageUrl: item.imageUrl,
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
            // ✅ FIX: Use item.imageUrl for remote loading
            imageUrl: item.imageUrl,
            name: item.name,
            longDescription: item.longDescription,
            salesDescription: item.salesDescription,
            price: item.price,
            originalPrice: item.originalPrice
        ).environmentObject(cart)) {
            MenuItemRow(
                // ✅ FIX: Use item.imageUrl for remote loading
                imageUrl: item.imageUrl,
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

// CheckoutBarView, HeaderView, InfoView, GroupOrderButton, CategoryHeaderView remain unchanged

struct HeaderView: View {
    let imageName: String
    // Assuming this is still a local asset (e.g., logo based on store.id)
    var body: some View { Image(imageName).resizable().scaledToFill().frame(height: 220).clipped() }
}

// ... other structs ...

struct MenuItemRow: View {
    // ✅ FIX: Changed imageName to imageUrl
    let imageUrl: String
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
            // ✅ FIX: Use KFImage for remote loading
            KFImage(URL(string: imageUrl))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
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
            
            // ... (Rest of the VStack for Add/Stepper buttons) ...
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
            // ✅ FIX: Initialize with only the required ViewModel
            RestaurantDetailView(viewModel: RestaurantDetailViewModel(storeId: "R01"))
        }
    }
}
