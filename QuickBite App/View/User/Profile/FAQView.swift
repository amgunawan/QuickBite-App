//
//  FAQView.swift
//  QuickBite App
//
//  Created by jessica tedja on 04/11/25.
//

import SwiftUI

struct FAQItem: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQRow: View {
    let item: FAQItem
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

                // Chevron icon
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

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedID: UUID? = nil

    private let faqs: [FAQItem] = [
        .init(
            question: "Can I pay with cash?",
            answer: "No, QuickBite UC supports only cashless payments like QRIS, GoPay, and OVO for convenience."
        ),
        .init(
            question: "How do I know when my order is ready?",
            answer: "You'll receive an in-app notification and the order will be marked 'Ready for pickup' on the Orders page."
        ),
        .init(
            question: "What is the Last-Call Sale?",
            answer: "A limited-time promotion for items nearing the end of availability that day—first come, first served."
        ),
        .init(
            question: "Is QuickBite available on weekends?",
            answer: "Operational hours follow the campus venue. Availability may vary on weekends and public holidays."
        ),
        .init(
            question: "How do I place an order?",
            answer: "Choose a menu item, customize options if available, then proceed to payment. You'll get a QR code to pick up."
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
                        FAQRow(item: item, expandedID: $expandedID)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 2)
            }
            .padding(.bottom, 24)
            
            Spacer()
        }
        .navigationTitle("FAQ")
    }
}


extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
