//
//  HomeView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct HomeView: View {
    @State private var searchText: String = ""
    @StateObject private var cuisineTypeVM = CuisineTypeViewModel()
    @StateObject private var restaurantVM = RestaurantsViewModel()
    @StateObject private var topRatedVM = TopRatedRestaurantsViewModel()
    @StateObject private var discountVM = HomeDiscountViewModel()
    
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search restaurants or dishes...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .disableAutocorrection(true)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                ScrollView {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Your Favorite Bites
                        VStack(alignment: .leading) {
                            Text("Your Favorite Bites")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(cuisineTypeVM.cuisineTypes, id: \.self) { item in
                                        NavigationLink(destination: FoodCategoryView(categoryName: item)) {
                                            VStack {
                                                Image(item)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 70, height: 70)
                                                    .clipShape(Circle())
                                                
                                                Text(item)
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onAppear {
                                cuisineTypeVM.fetchCuisineTypes()
                            }
                        }
                        
                        // Discount Deals
                        if !discountVM.discountDeals.isEmpty || discountVM.isLoading {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Discount Deals")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    // "See All" Link - Only appears when data is ready
                                    if !discountVM.discountDeals.isEmpty {
                                        NavigationLink(destination: AllDealsView(viewModel: discountVM)) {
                                            Text("See all")
                                                .font(.subheadline)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        
                                        // A. LOADING STATE: Show Skeletons
                                        // This runs while the app is downloading the JSON menu files
                                        if discountVM.isLoading && discountVM.discountDeals.isEmpty {
                                            ForEach(0..<3, id: \.self) { _ in
                                                VStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 140, height: 100)
                                                    
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 100, height: 16)
                                                    
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 60, height: 16)
                                                }
                                                .frame(width: 140, height: 160)
                                            }
                                        }
                                        
                                        // B. LOADED STATE: Show Real Cards
                                        else {
                                            ForEach(discountVM.discountDeals) { deal in
                                                // Link to RestaurantDetail if clicked (optional)
                                                // NavigationLink(destination: RestaurantDetailView(...)) {
                                                DealCardView(deal: deal)
                                                // }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Sync Calendar Assistant
                        if !calendarManager.isSynced {
                            ZStack {
                                // Background Gradient
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Let Us Be Your Assistant! ⏰")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("Sync your calendar to get pickup time recommendations that fit your class schedule.")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.9))
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        NavigationLink(destination: SyncCalendarView()) {
                                            Text("Sync My Calendar")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.orange)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.white)
                                                .cornerRadius(20)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                    
                                    // Background Icon (Calendar)
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 110, height: 120)
                                        .foregroundColor(.white.opacity(0.2))
                                        .padding(.trailing, -10)
                                        .padding(.bottom, -60)
                                    
                                    
                                }
                            }
                            .frame(height: 140)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .clipped()
                        }
                        
                        // Top-Rated Restaurants
                        VStack(alignment: .leading) {
                            Text("Top-Rated Restaurants")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    
                                    ForEach(topRatedVM.topRestaurants) { restaurant in
                                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                            TopRatedRestaurantsCardView(
                                                imageURL: restaurant.bannerURL,
                                                deliveryTime: restaurant.deliveryTime,
                                                name: restaurant.name,
                                                rating: String(format: "%.1f", restaurant.rating),
                                                reviewCount: restaurant.reviewCount == 0
                                                    ? "No rating"
                                                    : "\(restaurant.reviewCount) ratings"
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onAppear {
                                topRatedVM.fetchTopRated()
                            }
                        }
                        
                        // All Restaurants
                        VStack(alignment: .leading) {
                            Text("All Restaurants")
                                .font(.headline)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                let columns = [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ]
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(restaurantVM.restaurants) { r in
                                        NavigationLink(destination: RestaurantDetailView(restaurant: r)) {
                                            AllRestaurantsCardView(
                                                imageURL: r.bannerURL,
                                                deliveryTime: r.deliveryTime, 
                                                name: r.name,
                                                rating: String(format: "%.1f", r.rating),
                                                reviewCount: r.reviewCount == 0 ? "No rating" : "\(r.reviewCount) ratings"
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .toolbar(.visible, for: .tabBar)
            .onAppear {
                print("HomeView Appeared - Triggering Fetches")
                discountVM.fetchDiscounts() // <--- Fetch Discounts
                cuisineTypeVM.fetchCuisineTypes()
                topRatedVM.fetchTopRated()
                restaurantVM.fetchRestaurants()
            }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(CalendarManager())
}
