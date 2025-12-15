//
//  MenuRow.swift
//  QuickBite
//
//  Created by student on 15/12/25.
//

import SwiftUI

struct MenuRow: View {

    let item: MenuItem
    let onEdit: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            MenuRowImage(imageURL: item.imageURL)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)

                StatusBadge(status: item.stockStatus)

                Text("Rp\(formatPrice(Double(item.price)))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }

            Spacer()

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
