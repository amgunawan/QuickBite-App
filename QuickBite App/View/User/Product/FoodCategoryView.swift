//
//  FoodCategoryView.swift
//  QuickBite
//
//  Created by Angela on 05/11/25.
//

import SwiftUI

struct FoodCategoryView: View {
    let categoryName: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 24) {
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.horizontal)
        .navigationTitle(categoryName)
    }
}

#Preview {
    DeleteAccountView()
}
