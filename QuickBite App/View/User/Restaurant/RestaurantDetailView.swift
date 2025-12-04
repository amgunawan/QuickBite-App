//
//  RestaurantDetailView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI


struct RestaurantDetailView: View {
    
    let restaurant: Restaurant
    
    @StateObject private var viewModel = RestaurantDetailViewModel()
    
    @State private var selectedItemForOptions: MenuItemModel?
    @State private var showingCart = false
    @StateObject private var topRatedVM = TopRatedRestaurantsViewModel()
    
    @StateObject private var cart = CartViewModel()
    
    @State private var isGroupOrderActive = false
    @State private var showingGroupCart = false
    
    @State private var groupName = "Angela's Group"
    
    @State private var groupMembers: [UserMember] = [
        UserMember(name: "Angela", username: "@angela", initial: "A", color: .orange, isCurrentUser: true)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    HeaderView(imageURL: restaurant.bannerURL ?? "")
                        .padding(.bottom)
                    
                    InfoView(
                        name: restaurant.name,
                        categories: restaurant.cuisineType.joined(separator: ", "),
                        rating: restaurant.rating,
                        reviewCount: restaurant.reviewCount,
                        pickupTime: "15-20 min", // Bisa dibuat dinamis nanti
                        isGroupOrderActive: $isGroupOrderActive,
                        groupName: $groupName,
                        groupMembers: $groupMembers
                    )
                    .padding(.horizontal)
                    
                    // MARK: - SECTION 1
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Sedang mengambil menu...")
                                .padding(.top, 50)
                            Spacer()
                        }
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ForEach(viewModel.groupedMenu) { section in
                            Section(header: CategoryHeaderView(title: section.category)) {
                                ForEach(section.items) { item in
                                    MenuRowLink(item: item) {
                                        self.selectedItemForOptions = item
                                    }
                                }
                            }
                        }
                    }
                    
                }
                .padding(.bottom, cart.items.isEmpty ? 0 : 80)
            }
            
            // MARK: - Checkout Bar
            if isGroupOrderActive {
                // Tampilkan Bar Khusus Grup (Screenshot 1)
                GroupOrderBottomBar(cart: cart, showGroupCart: $showingGroupCart)
            } else if !cart.items.isEmpty {
                // Tampilkan Bar Checkout Biasa
                CheckoutBarView(showCart: $showingCart)
            }
        }
        .environmentObject(cart)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchMenu(from: restaurant.menuDataURL)
        }
        .sheet(item: $selectedItemForOptions) { item in
            MenuOptionsView(
                imageName: item.imageURL ?? "", // Kirim URL gambar
                name: item.name,
                salesDescription: item.description ?? "Enak banget!", // Pakai deskripsi
                price: Double(item.price),      // Konversi Int ke Double
                originalPrice: nil              // Model belum punya harga coret, set nil
            )
            .environmentObject(cart)            // ⚠️ PENTING: Jangan lupa kirim Cart
        }
        .sheet(isPresented: $showingCart) {
            CartListView() // Pastikan View ini ada
                .environmentObject(cart)
        }
        .sheet(isPresented: $showingGroupCart) {
            GroupCartView().environmentObject(cart) // Pastikan View ini ada
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - MENU ROW LINK
struct MenuRowLink: View {
    let item: MenuItemModel
    let onAdd: () -> Void
    
    @EnvironmentObject var cart: CartViewModel
    
    var body: some View {
        // Navigasi ke Detail Menu (Opsional)
        // Kalau mau pakai NavigationLink, pastikan MenuDetailView juga menerima 'MenuItem'
        MenuItemRow(
            imageURL: item.imageURL,
            name: item.name,
            description: item.description ?? "",
            price: Double(item.price),
            originalPrice: nil, // JSON kamu belum ada original price, set nil dulu
            onAdd: onAdd
        )
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle()) // Agar area kosong bisa diklik
        .onTapGesture {
            onAdd() // Langsung buka sheet opsi saat baris diklik
        }
    }
}

// Update MenuItemRow agar pakai AsyncImage (URL) bukan Image(named)
struct MenuItemRow: View {
    let imageURL: String?
    let name: String
    let description: String
    let price: Double
    let originalPrice: Double?
    let onAdd: () -> Void
    
    // Perbaikan logic quantity (sesuaikan dengan nama item)
    @EnvironmentObject var cart: CartViewModel
    
    var quantity: Int {
        cart.items.filter { $0.name == name }.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // FOTO DARI URL
            if let stringUrl = imageURL, let url = URL(string: stringUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 90, height: 90)
                .cornerRadius(8)
                .clipped()
            } else {
                // Placeholder kalau tidak ada foto
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 90, height: 90)
                    .cornerRadius(8)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("Rp\(formatPrice(price))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.orange)
                    
                    if let originalPrice = originalPrice {
                        Text("Rp\(formatPrice(originalPrice))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                }
            }
            
            Spacer()
            
            // TOMBOL PLUS/MINUS
            VStack {
                Spacer()
                if quantity > 0 {
                    HStack(spacing: 8) {
                        Button {
                            // Logic kurangi cart
                            if let index = cart.items.lastIndex(where: { $0.name == name }) {
                                cart.decrementItem(id: cart.items[index].id)
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange, lineWidth: 1))
                        }
                        
                        Text("\(quantity)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
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
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .frame(height: 90) // Kunci tinggi baris agar rapi
    }
}

// ==================================================================
// --- SUB-VIEWS (Components) ---
// ==================================================================

struct CheckoutBarView: View {
    
    @EnvironmentObject var cart: CartViewModel
    @Binding var showCart: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            
            Button(action: { showCart = true }) {
                HStack(spacing: 16) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "basket")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                            .padding(.trailing, 2)
                        
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
                    
                    VStack(alignment: .trailing) {
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
            
            Button(action: {
                showCart = true
            }) {
                Text("View Cart")
                    .font(.system(size: 16, weight: .medium))
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

struct GroupOrderBottomBar: View {
    @ObservedObject var cart: CartViewModel
    @Binding var showGroupCart: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Ikon Basket (Orange Outline) dengan Badge
            Button(action: { showGroupCart = true }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "basket")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                        .padding(.trailing, 2)
                    
                    // Hitung total item (misal +1 item user lain sbg dummy)
                    let totalItems = cart.totalItemCount // + user lain jika ada
                    if totalItems > 0 {
                        Text("\(totalItems)")
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
                
                // Text Total Harga (User saja)
                // Menggunakan Group untuk menghindari error type check pada + operator
                VStack(alignment: .trailing) {
                    Text("Rp\(formatPrice(cart.totalPrice))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text(" (Total: Rp\(formatPrice(cart.totalPrice + 42500)))") // Dummy total grup
                        .font(.system(size:14))
                        .foregroundColor(.orange)
                }
            }
            .buttonStyle(.plain)
            
            // Tombol View Cart
            Button(action: {
                showGroupCart = true
            }) {
                Text("View Cart")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(25)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
    }
}

// MARK: - Header
struct HeaderView: View {
    let imageURL: String
    
    var body: some View {
        if let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .overlay(ProgressView())
            }
            .frame(height: 220)
            .clipped()
        } else {
            Rectangle()
                .fill(.gray.opacity(0.2))
                .frame(height: 220)
        }
    }
}

// MARK: - Info View
struct InfoView: View {
    let name: String
    let categories: String
    let rating: Double
    let reviewCount: Int
    let pickupTime: String
    
    @Binding var isGroupOrderActive: Bool
    @Binding var groupName: String
    @Binding var groupMembers: [UserMember]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name).font(.system(size: 28, weight: .bold))
                    Text(categories).font(.body).foregroundColor(.gray)
                }
                Spacer()
                NavigationLink(destination: GroupOrderView(restaurantName: name, isGroupOrderActive: $isGroupOrderActive, groupName: $groupName, groupMembers: $groupMembers)) {
                    GroupOrderButton(title: isGroupOrderActive ? groupName : "Group Order")
                }
                .padding(.top, 4)          }
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
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

// MARK: - Group Order Button
struct GroupOrderButton: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.2.fill")
            Text(title).font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color.orange.opacity(0.08)).foregroundColor(.orange).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.orange, lineWidth: 1.5))
    }
}

// MARK: - FIXED HEADER (IMPORTANT)
struct CategoryHeaderView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 8)
                .padding(.vertical, 16)
            
            ZStack(alignment: .leading) {
                Color.white.frame(height: 25)
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color.white)
    }
}

// MARK: - Menu Row


struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyResto = Restaurant(
            id: "123",
            name: "Raburi Test",
            location: "UC Walk",
            rating: 4.8,
            reviewCount: 100,
            bannerURL: nil,
            searchURL: nil,
            cuisineType: ["Japanese", "Noodles"],
            menuDataURL: "gs://quickbite-app-fb529.firebasestorage.app/Raburi/menu.json"
        )
        
        NavigationStack {
            RestaurantDetailView(restaurant: dummyResto)
        }
    }
}
