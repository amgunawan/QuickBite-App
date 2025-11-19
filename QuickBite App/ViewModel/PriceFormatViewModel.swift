//
//  PriceFormatViewModel.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import Foundation

// MARK: - Price Formatter
func formatPrice(_ value: Double) -> String {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.groupingSeparator = "."
    return nf.string(from: NSNumber(value: value)) ?? "0"
}
