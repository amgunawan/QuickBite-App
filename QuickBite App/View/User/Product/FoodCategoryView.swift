//
//  FoodCategoryView.swift
//  QuickBite
//
//  Created by Angela on 05/11/25.
//

import SwiftUI

struct FoodCategoryView: View {
    let categoryName: String
    @StateObject private var vm = FoodCategoryViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ScrollView(.vertical, showsIndicators: false) {
                if vm.stores.isEmpty {
                    Text("No restaurant found.")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                else {
                    let columns = [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        
                        ForEach(vm.stores) { store in
                            AllRestaurantsCardView(
                                imageURL: store.bannerURL,
                                deliveryTime: "<10 min",
                                name: store.name,
                                rating: String(format: "%.1f", store.rating),
                                reviewCount: store.reviewCount == 0 ? "No rating" : "\(store.reviewCount) ratings"
                            )
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle(categoryName)
        .onAppear {
            vm.fetchStores(by: categoryName)
        }
    }
}
