//
//  RestaurantDetailView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct RestaurantDetailView: View {
    
    let restaurant: Restaurant
    
    @EnvironmentObject var navState: AppNavigationState
    
    @StateObject private var viewModel = RestaurantDetailViewModel()
    @EnvironmentObject var cart: CartViewModel
    
    @State private var selectedItemForOptions: MenuItem?
    @State private var showingGroupCart = false
    @State private var isGroupOrderActive = false
    
    @State private var groupName = "My Group"
    @State private var groupMembers: [UserMember] = []
    
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
                        pickupTime: "15–20 min",
                        isGroupOrderActive: $isGroupOrderActive,
                        groupName: $groupName,
                        groupMembers: $groupMembers
                    )
                    .padding(.horizontal)
                    
                    // Section 1
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading menu...")
                                .padding(.top, 50)
                            Spacer()
                        }
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ForEach(viewModel.groupedMenu) { section in
                            Section(
                                header: CategoryHeaderView(title: section.category)
                            ) {
                                ForEach(section.items) { item in
                                    let priceInfo = viewModel.getPriceInfo(for: item)
                                    
                                    MenuRowLink(
                                        item: item,
                                        finalPrice: priceInfo.finalPrice,
                                        originalPrice: priceInfo.originalPrice,
                                        onAdd: {
                                            selectedItemForOptions = item
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, cart.items.isEmpty ? 0 : 80)
            }
            
            if isGroupOrderActive {
                GroupOrderBottomBar(cart: cart, showGroupCart: $showingGroupCart)
            } else if !cart.items.isEmpty {
                CheckoutBarView(showCart: $navState.isCartPresented)
            }
        }
        .environmentObject(cart)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            
            fetchCurrentUser()
            
            if let menuLink = restaurant.menuDataURL, !menuLink.isEmpty {
                viewModel.fetchMenu(from: menuLink)
            }
            
            if let storeID = restaurant.id {
                viewModel.fetchDiscounts(storeID: storeID)
            }
        }
        
        .sheet(item: $selectedItemForOptions) { item in
            let priceInfo = viewModel.getPriceInfo(for: item)
            
            MenuOptionsView(
                restaurantName: restaurant.name,
                restaurantId: restaurant.id ?? "",
                item: item,
                finalPrice: priceInfo.finalPrice,
                originalPrice: priceInfo.originalPrice,
                itemToEdit: nil
            )
            .environmentObject(cart)
        }
        
        .sheet(isPresented: $navState.isCartPresented) {
            CartListView().environmentObject(cart)
        }
        
        .sheet(isPresented: $showingGroupCart) {
            GroupCartView().environmentObject(cart)
        }
        .scrollIndicators(.hidden)
    }
    
    func fetchCurrentUser() {
            if let user = Auth.auth().currentUser {
                let name = user.displayName ?? (user.email?.components(separatedBy: "@").first ?? "User")
                let initial = String(name.prefix(1)).uppercased()
                
                // Set Group Name
                self.groupName = "\(name)'s Group"
                
                // Set Group Members
                self.groupMembers = [
                    UserMember(
                        name: name,
                        username: user.email ?? "",
                        initial: initial,
                        color: .orange,
                        isCurrentUser: true
                    )
                ]
            }
        }
}

struct MenuRowLink: View {
    let item: MenuItem
    let finalPrice: Double
    let originalPrice: Double?
    let onAdd: () -> Void
    
    @EnvironmentObject var cart: CartViewModel
    
    var body: some View {
        ZStack{
            NavigationLink {
                MenuDetailView(
                    item: item,
                    customFinalPrice: finalPrice,
                    customOriginalPrice: originalPrice
                )
                .environmentObject(cart)
            } label: {
                MenuItemRow(
                    imageURL: item.imageURL,
                    name: item.name,
                    description: item.description ?? "",
                    price: finalPrice,
                    originalPrice: originalPrice,
                    onAdd: onAdd
                )
                .padding(.horizontal)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

struct MenuItemRow: View {
    let imageURL: String?
    let name: String
    let description: String
    let price: Double
    let originalPrice: Double?
    let onAdd: () -> Void
    
    @EnvironmentObject var cart: CartViewModel
    
    var quantity: Int {
        cart.items.filter { $0.name == name }.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        HStack(spacing: 16) {
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
                
                HStack(spacing: 4) {
                    Text("Rp\(formatPrice(price))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.orange)
                    
                    if let originalPrice {
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
                        .buttonStyle(PlainButtonStyle())
                        
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
                        .buttonStyle(PlainButtonStyle())
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
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(height: 90) 
    }
}

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

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // 1. Create dummy data
        let dummy = Restaurant(
            id: "123",
            name: "Raburi Test",
            location: "UC Walk",
            rating: 4.8,
            reviewCount: 100,
            bannerURL: "gs://quickbite-app-fb529.firebasestorage.app/Raburi/main/banner.jpg",
            searchURL: nil,
            cuisineType: ["Japanese", "Noodles"],
            menuDataURL: "gs://quickbite-app-fb529.firebasestorage.app/Raburi/menu.json"
        )
        
        // 2. Create a dummy cart
        let mockCart = CartViewModel()

        NavigationStack {
            RestaurantDetailView(restaurant: dummy)
        }
        // 3. INJECT the cart environment object
        .environmentObject(mockCart)
        .onAppear {
            // 4. Prevent Firebase crash in Previews
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
        }
    }
}
