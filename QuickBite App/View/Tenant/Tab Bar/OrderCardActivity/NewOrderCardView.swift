//
//  NewOrderCardView.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI
import Foundation


struct NewOrderCardView: View {
    let order: OrderCardViewData
    var onAccept: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.name)
                    .font(.headline)
                Text("Pick up at \(order.pickupTime)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            ForEach(order.items, id: \.self) { item in
                Text(item)
            }
            
            Divider()
            
            Text("Total: \(order.total)")
                .fontWeight(.bold)
            
            Divider()
            
            HStack {
                Button("Accept") {
                    onAccept?()
                }
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(24)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5))
                .background(Color.white.cornerRadius(16))
        )
    }
}

// PREVIEW
//#Preview {
//    NewOrderCardView(
//        order: OrderCardViewData(
//            name: "Angela Melia",
//            pickupTime: "12:00 PM",
//            items: ["1x Chicken Ramen", "1x Ocha"],
//            total: "Rp 45.000"
//        )
//    )
//}
