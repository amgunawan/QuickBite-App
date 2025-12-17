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

// MARK: - Time Formatter
func formatTime(_ date: Date?) -> String {
    guard let date else { return "-" }
    let f = DateFormatter()
    f.dateFormat = "h:mm a"
    return f.string(from: date)
}
