//
//  DealCardView.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import SwiftUI

struct DealCardView: View {
    let deal: DiscountDisplayItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: deal.imageURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.1) // Placeholder color
                    }
                }
                .frame(width: 150, height: 100)
                .clipped()
                
                // Promo Tag
                Text("Promo")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
                    .padding(8)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(deal.itemName)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(deal.storeName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack() {
                    Text("Rp\(Int(deal.finalPrice))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("Rp\(Int(deal.originalPrice))")
                        .font(.system(size: 11))
                        .strikethrough()
                        .foregroundColor(.gray)
                }
            }
            .padding(10)
        }
        .frame(width: 150)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

//#Preview {
//    ZStack {
//        // Gray background to help visualize the card's border and white background
//        Color(.systemGray6)
//            .ignoresSafeArea()
//        
//        // 1. Create a Dummy MenuItem for the preview
//        let dummyItem = MenuItem(
//            itemId: "1",
//            name: "Chicken Katsu Shirokara Ramen",
//            description: "Delicious ramen",
//            price: 35000,
//            category: "Ramen",
//            imageURL: nil,
//            defaultStock: 10,
//            prepTimeMinutes: 15,
//            options: nil
//        )
//        
//        // 2. Create the Deal using the dummy item
//        DealCardView(deal: DiscountDisplayItem(
//            id: "preview_1",
//            discountAmount: 5000,
//            originalPrice: 35000,
//            finalPrice: 30000,
//            itemName: "Chicken Katsu Shirokara Ramen",
//            storeName: "Raburi",
//            imageURL: "https://via.placeholder.com/150",
//            storeId: "store_123",
//            menuItem: dummyItem
//        ))
//    }
//}
