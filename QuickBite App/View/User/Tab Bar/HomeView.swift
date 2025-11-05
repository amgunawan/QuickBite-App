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
                                    ForEach(["Snacks", "Rice", "Noodles", "Chicken", "Korean", "Japanese", "Beverages", "Chinese", "Western"], id: \.self) { item in
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
                        }
                        
                        // Today's Limited Deals
                        VStack(alignment: .leading) {
                            Text("Today's Limited Deals")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                let rows = [
                                    GridItem(.fixed(90)),
                                    GridItem(.fixed(90))
                                ]
                                
                                LazyHGrid(rows: rows, spacing: 16) {
                                    DealCardView(
                                        imageName: "ChickenKatsuShirokaraRamen",
                                        title: "Chicken Katsu Shirokara Ramen",
                                        restaurant: "Raburi",
                                        priceNow: "Rp30.000",
                                        priceOld: "Rp35.000"
                                    )
                                    
                                    DealCardView(
                                        imageName: "SteamedChicken",
                                        title: "Steamed Chicken",
                                        restaurant: "Paus Puas",
                                        priceNow: "Rp28.000",
                                        priceOld: "Rp35.000"
                                    )
                                    
                                    DealCardView(
                                        imageName: "NasiAyamGeprek",
                                        title: "Nasi Ayam Geprek",
                                        restaurant: "Madame Liy",
                                        priceNow: "Rp25.000",
                                        priceOld: "Rp28.000"
                                    )
                                    
                                    DealCardView(
                                        imageName: "DonatJadoel",
                                        title: "Donal Jadoel",
                                        restaurant: "Gisoe Coffee",
                                        priceNow: "Rp4.000",
                                        priceOld: "Rp7.000"
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Top-Rated Restaurants
                        VStack(alignment: .leading) {
                            Text("Top-Rated Restaurants")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    TopRatedRestaurantsCardView(
                                        imageName: "Raburi",
                                        deliveryTime: "10–20 min",
                                        name: "Raburi"
                                    )
                                    
                                    TopRatedRestaurantsCardView(
                                        imageName: "KPatats",
                                        deliveryTime: "<10 min",
                                        name: "King Patats"
                                    )
                                    
                                    TopRatedRestaurantsCardView(
                                        imageName: "MadameLiy",
                                        deliveryTime: "10–20 min",
                                        name: "Madame Liy"
                                    )
                                    
                                    TopRatedRestaurantsCardView(
                                        imageName: "KayaBoys",
                                        deliveryTime: "<10 min",
                                        name: "Kaya Boys"
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // All Restaurants
                        VStack(alignment: .leading) {
                            HStack {
                                Text("All Restaurants")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.down")
                            }
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                let columns = [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ]
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    AllRestaurantsCardView(
                                        imageName: "KayaBoys",
                                        deliveryTime: "<10 min",
                                        name: "Kaya Boys"
                                    )
                                    
                                    AllRestaurantsCardView(
                                        imageName: "KPatats",
                                        deliveryTime: "<10 min",
                                        name: "King Patats"
                                    )
                                    
                                    AllRestaurantsCardView(
                                        imageName: "MadameLiy",
                                        deliveryTime: "10–20 min",
                                        name: "Madame Liy"
                                    )
                                    
                                    AllRestaurantsCardView(
                                        imageName: "Raburi",
                                        deliveryTime: "10–20 min",
                                        name: "Raburi"
                                    )
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
        }
    }
}
