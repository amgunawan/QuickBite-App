//
//  MenuRow.swift
//  QuickBite
//
//  Created by student on 15/12/25.
//

import SwiftUI

struct MenuRow: View {

    let item: MenuItem
    let showStockBadge: Bool
    let onEdit: () -> Void

    // MARK: - Computed UI Values

    private var displayName: String {
        let trimmed = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "New Item" : trimmed
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // IMAGE
            MenuRowImage(
                imageURL: item.imageURL,
                draftImage: item.draftImage
            )
            
            // INFO
            VStack(alignment: .leading, spacing: 6) {

                // ITEM NAME (with placeholder)
                Text(displayName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)

                // STOCK BADGE (conditionally shown)
                if showStockBadge {
                    StatusBadge(status: item.stockStatus)
                }

                // PRICE
                Text("Rp\(formatPrice(Double(item.price)))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }

            Spacer()

            // EDIT BUTTON
            Button(action: onEdit) {
                Text("Edit")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15), in: Capsule())
            }
        }
    }
}
