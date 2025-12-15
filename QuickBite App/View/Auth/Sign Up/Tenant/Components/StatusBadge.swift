//
//  StatusBadge.swift
//  QuickBite
//
//  Created by student on 15/12/25.
//

import SwiftUI

struct StatusBadge: View {
    let status: StockStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background, in: Capsule())
    }

    private var textColor: Color {
        switch status {
        case .inStock: return .white
        case .lowStock: return .black
        case .outOfStock: return .white
        }
    }

    private var background: Color {
        switch status {
        case .inStock: return .green
        case .lowStock: return .yellow.opacity(0.9)
        case .outOfStock: return .red
        }
    }
}

