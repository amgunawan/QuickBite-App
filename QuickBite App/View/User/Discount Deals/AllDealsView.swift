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
    
    // Define the custom colors based on your design
    let headerRed = Color(red: 0.95, green: 0.3, blue: 0.1) // Vibrant Red-Orange
    let listBackground = Color(red: 1.0, green: 0.98, blue: 0.95) // Light Beige for list bg
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - LAYER 1: Background Color (The Fix)
            // This sits behind everything and fills the top notch
            headerRed
                .ignoresSafeArea(edges: .top)
                .frame(height: 150) // Height of the red header part
            
            // MARK: - LAYER 2: Main Content
            VStack(spacing: 0) {
                
                // --- CUSTOM HEADER ---
                VStack(spacing: 8) {
                    // Top Row: Back Button & Title
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white.opacity(0.4))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Discount Deals")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Invisible placeholder for centering
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .padding(10)
                            .opacity(0)
                    }
                    
                    // Subtitle
                    Text("Grab your discount deals before it ends")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .padding(.bottom, 10) // Extra padding for the curve
                .background(headerRed) // Matches the ZStack background
                // Round only bottom corners
                .clipShape(
                    RoundedCorners(radius: 30, corners: [.bottomLeft, .bottomRight])
                )
                
                // --- SCROLLABLE LIST ---
                ZStack {
                    // Fill the scrollview area with light beige
                    listBackground.ignoresSafeArea(edges: .bottom)
                    
                    ScrollView {
                        VStack(spacing: 12) { // Spacing between items
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding(.top, 50)
                            } else if viewModel.discountDeals.isEmpty {
                                Text("No deals found right now.")
                                    .foregroundColor(.gray)
                                    .padding(.top, 50)
                            } else {
                                ForEach(viewModel.discountDeals) { deal in
                                    DiscountListRow(deal: deal)
                                }
                            }
                            
                            // "That's all for now" Footer
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
                                .padding(.vertical, 30)
                            }
                        }
                        .padding(.vertical, 16) // Padding at top of list
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.discountDeals.isEmpty {
                viewModel.fetchDiscounts()
            }
        }
    }
}

// MARK: - NEW LIST ITEM COMPONENT (Matches Reference Image)
struct DiscountListRow: View {
    let deal: DiscountDisplayItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 1. Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: deal.imageURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
                
                // Tag on Image (Top Right)
                if deal.originalPrice > 0 {
                    let percentage = Int((Double(deal.discountAmount) / deal.originalPrice) * 100)
                    Text("-\(percentage)%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(6)
                        .padding(4)
                }
            }
            
            // 2. Center Info (Title, Store, Price)
            VStack(alignment: .leading, spacing: 4) {
                Text(deal.itemName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.black)
                
                Text(deal.storeName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Rp\(Int(deal.finalPrice))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("Rp\(Int(deal.originalPrice))")
                        .font(.caption)
                        .strikethrough()
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            .frame(height: 80) // Match image height
            
            Spacer()
            
            // 3. Add to Cart Button (Right Side)
            VStack {
                Spacer()
                Button(action: {
                    // Action
                }) {
                    Text("Add to Cart")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(16)
                }
            }
            .frame(height: 80)
        }
        .padding(12)
        .background(Color.white) // White card background
        .cornerRadius(12) // Rounded corners for the row
        .padding(.horizontal, 16) // Padding from screen edges
        // Optional: Add subtle shadow if desired
        // .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    let mockVM = HomeDiscountViewModel()
    mockVM.discountDeals = [
        DiscountDisplayItem(id: "1", discountAmount: 5000, originalPrice: 35000, finalPrice: 30000, itemName: "Chicken Katsu Shirokara Ramen", storeName: "Raburi", imageURL: "", storeId: "s1"),
        DiscountDisplayItem(id: "2", discountAmount: 10000, originalPrice: 20000, finalPrice: 10000, itemName: "Matcha Iced Tea", storeName: "Tuku-Tuku", imageURL: "", storeId: "s2")
    ]
    return AllDealsView(viewModel: mockVM)
}
