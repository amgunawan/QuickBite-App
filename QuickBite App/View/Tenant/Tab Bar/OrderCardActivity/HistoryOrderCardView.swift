//
//  HistoryOrderCardView.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI
import Foundation


struct HistoryOrderCardView: View {

    let order: OrderCardViewData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // ===== HEADER (Name + Completed)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.name)
                        .font(.headline)

                    Text("Pick up at \(order.pickupTime)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("Completed")
                    .foregroundColor(Color.orange)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            // ===== ITEMS
            ForEach(order.items, id: \.self) { item in
                Text(item)
                    .font(.subheadline)
            }

            Divider()

            // ===== TOTAL
            Text("Total: \(order.total)")
                .fontWeight(.bold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5))
                .background(Color.white.cornerRadius(16))
        )
    }
}
