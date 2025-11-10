//
//  FAQTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 05/11/25.
//

import SwiftUI

struct FAQTenantItem: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - Row
struct FAQTenantRow: View {
    let item: FAQTenantItem
    @Binding var expandedID: UUID?

    private var isExpanded: Bool { expandedID == item.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text(item.question)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right")
                    .foregroundColor(isExpanded ? Color(hex: "FF9500") : Color(uiColor: .tertiaryLabel))
                    .imageScale(.medium)
            }

            if isExpanded {
                Text(item.answer)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isExpanded ? Color(hex: "FF9500") : Color.black.opacity(0.08),
                        lineWidth: isExpanded ? 1.5 : 0.8)
        )
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.18)) {
                expandedID = isExpanded ? nil : item.id
            }
        }
    }
}

// MARK: - Screen
struct FAQTenantView: View {
    @State private var expandedID: UUID? = nil

    private let faqs: [FAQTenantItem] = [
        .init(
            question: "How do I change my store’s operating hours?",
            answer: "Profile → “Edit Store Details” → set Opening/Closing Time or Weekly Schedule → Save."
        ),
        .init(
            question: "Item is out-of-stock. What do I do?",
            answer: "Go to Manage Menu & Stock → choose the item → toggle Off/Out of Stock so customers can’t order it."
        ),
        .init(
            question: "How often are our earnings paid out?",
            answer: "Go to Financial & Payouts to view payout schedule and destination account. Bank processing may vary by provider."
        ),
        .init(
            question: "How can I temporarily hide a menu item?",
            answer: "Manage Menu & Stock → select the item → Hide/Disable. You can re-enable it anytime."
        ),
        .init(
            question: "How do I get assistance if the app has a bug?",
            answer: "Open Help & Support → Report an Issue. Include screenshots, order ID (if any), and the steps to reproduce."
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Find answers to commonly asked questions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                VStack(spacing: 12) {
                    ForEach(faqs) { item in
                        FAQTenantRow(item: item, expandedID: $expandedID)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 2)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 24)
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//// MARK: - Helpers
//extension Color {
//    init(hex: String) {
//        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        if s.hasPrefix("#") { s.removeFirst() }
//        var rgb: UInt64 = 0
//        Scanner(string: s).scanHexInt64(&rgb)
//        self.init(
//            red:   Double((rgb >> 16) & 0xFF) / 255,
//            green: Double((rgb >>  8) & 0xFF) / 255,
//            blue:  Double((rgb >>  0) & 0xFF) / 255
//        )
//    }
//}

#Preview {
    FAQTenantView()
}
