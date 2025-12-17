//
//  AllDealsView.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import SwiftUI

struct AllDealsView: View {
    @ObservedObject var viewModel: HomeDiscountViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Define custom colors
    let headerRed = Color(red: 0.95, green: 0.3, blue: 0.1) // Vibrant Red-Orange
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - LAYER 1: Background Color
            headerRed
                .ignoresSafeArea(edges: .top)
                .frame(height: 150)
            
            // MARK: - LAYER 2: Main Content
            VStack(spacing: 0) {
                
                // --- CUSTOM HEADER (Subtitle Only) ---
                VStack(spacing: 8) {
                    Spacer().frame(height: 10) // Spacer for Native Nav Bar
                    
                    Text("Grab your discount deals before it ends")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(headerRed)
                .clipShape(
                    RoundedCorners(radius: 30, corners: [.bottomLeft, .bottomRight])
                )
                
                // --- SCROLLABLE LIST ---
                ScrollView {
                    VStack(spacing: 0) {
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 50)
                        } else if viewModel.discountDeals.isEmpty {
                            Text("No deals found right now.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(Array(viewModel.discountDeals.enumerated()), id: \.element.id) { index, deal in
                                
                                // 1. Item Card
                                DiscountListRow(deal: deal)
                                
                                // 2. Divider
                                if index < viewModel.discountDeals.count - 1 {
                                    Rectangle()
                                        .fill(Color.orange.opacity(0.15))
                                        .frame(height: 8)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        
                        // Footer
                        if !viewModel.discountDeals.isEmpty {
                            VStack(spacing: 4) {
                                Text("That's all for now!")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Text("You've seen all the current discounts. Don't worry,\nmore deals will drop soon!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 50)
                        }
                    }
                    .padding(.top, 20)
                }
                .background(Color.white)
            }
        }
        // ✅ NATIVE NAVIGATION BAR SETUP
        .navigationTitle("Discount Deals")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(.black)
        .foregroundColor(.black)
        .onAppear {
            if viewModel.discountDeals.isEmpty {
                viewModel.fetchDiscounts()
            }
        }
    }
}

// MARK: - ROW COMPONENT
struct DiscountListRow: View {
    let deal: DiscountDisplayItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            
            // 1. Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: deal.imageURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 100, height: 100)
                .cornerRadius(12)
                .clipped()
                
                // Tag
                if deal.originalPrice > 0 {
                    let percentage = Int((Double(deal.discountAmount) / deal.originalPrice) * 100)
                    Text("-\(percentage)%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.red.opacity(0.95))
                        .cornerRadius(6)
                        .padding(6)
                }
            }
            
            // 2. Info
            VStack(alignment: .leading, spacing: 4) {
                Text(deal.itemName)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(2)
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(deal.storeName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Rp\(Int(deal.finalPrice))")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("Rp\(Int(deal.originalPrice))")
                        .font(.caption)
                        .strikethrough()
                        .foregroundColor(.gray.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .frame(height: 100)
            
            Spacer()
            
            // 3. Add Button -> Navigates to MenuDetailView
            VStack {
                Spacer()

                let tempRestaurant = Restaurant(
//                    id: deal.storeId.replacingOccurrences(of: "stores/", with: ""), // Clean ID
                    name: deal.storeName,
                    location: "", // Placeholder
                    cuisineType: [],
                    rating: 0.0,  // Placeholder
                    reviewCount: 0,
                    bannerURL: nil,
                    searchURL: nil,
                    menuDataURL: deal.menuDataURL, // ✅ Passed from ViewModel
                    deliveryTime: "30 min" // Placeholder
                )
                
                NavigationLink(destination:
                                RestaurantDetailView(
                                    restaurant: tempRestaurant,
                                    openItem: deal.menuItem
                                )
                ) {
                    Text("Add")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(20)
                }
            }
            .frame(height: 100)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AllDealsView(viewModel: HomeDiscountViewModel())
    }
    .environmentObject(CartViewModel())
}
