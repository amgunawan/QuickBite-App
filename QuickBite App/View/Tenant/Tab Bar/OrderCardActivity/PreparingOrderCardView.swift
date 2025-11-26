//
//  PreparingOrderCardView.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI
import Foundation


struct PreparingOrderCardView: View {
    
    let order: OrderCardViewData
    var onMarkAsReady: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.name)
                        .font(.headline)
                    Text("Pick up at \(order.pickupTime)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Spacer()
                Text("Preparing…")
                    .foregroundColor(.blue)
            }
            
            ForEach(order.items, id: \.self) { item in
                Text(item)
            }
            
            Divider()
            
            Text("Total: \(order.total)")
                .fontWeight(.bold)
            
            Divider()
            
            Button(action: { onMarkAsReady?() }) {
                Text("Mark as Ready")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
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


#Preview {
    PreparingOrderCardView(
        order: OrderCardViewData(
            name: "Rayna Shera",
            pickupTime: "12:00 PM",
            items: ["1x Chicken Teriyaki Shirokara Ramen", "1x Hot Ocha"],
            total: "Rp 46.000"
        ),
        onMarkAsReady: {}
    )
}
