//
//  TermsServiceView.swift
//  QuickBite App
//
//  Created by jessica tedja on 04/11/25.
//

import SwiftUI

struct TermsServiceView: View {
    @Environment(\.dismiss) private var dismiss
    private let brandOrange = Color(red: 1.0, green: 0.584, blue: 0.0)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last updated: October 28, 2025")
                            .font(.footnote)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        Text("Please read these terms and conditions carefully before using our service.")
                            .font(.footnote)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
                    .padding(.top, 2)

                    DividerThin()

                    SectionBlock(
                        number: 1,
                        title: "Acceptance of Terms",
                        bodyText: """
By accessing and using QuickBite, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use our service.
"""
                    )

                    DividerThin()

                    SectionBlock(
                        number: 2,
                        title: "User Account",
                        bodyText: """
You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.
""",
                        bullets: [
                            "Keep your password secure",
                            "Notify us of any unauthorized access",
                            "Accept responsibility for account activities"
                        ]
                    )

                    DividerThin()

                    SectionBlock(
                        number: 3,
                        title: "Orders and Payment",
                        bodyText: """
All orders are subject to acceptance and availability. Payment must be completed before order preparation begins.
""",
                        bullets: [
                            "Prices subject to change without notice",
                            "Payment required before preparation",
                            "We reserve the right to refuse any order"
                        ]
                    )

                    DividerThin()

                    SectionBlock(
                        number: 4,
                        title: "Privacy & Data Protection",
                        bodyText: """
We are committed to protecting your privacy. Your personal information is collected and processed in accordance with applicable data protection laws. We do not sell or share your data with third parties without consent.
"""
                    )

                    DividerThin()

                    SectionBlock(
                        number: 5,
                        title: "Limitation of Liability",
                        bodyText: """
QuickBite shall not be liable for any indirect, incidental, special, consequential or punitive damages resulting from your use of or inability to use the service. Our total liability shall not exceed the amount you paid for the order.
"""
                    )

                    DividerThin()

                    SectionBlock(
                        number: 6,
                        title: "Changes to Terms",
                        bodyText: """
We reserve the right to modify these terms at any time. Changes will be effective immediately upon posting. Your continued use of the service after changes constitutes acceptance of the new terms.
"""
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text("If you have any questions about these Terms, please contact us at")
                            .font(.footnote)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        Link("legal@quickbite.com",
                             destination: URL(string: "mailto:legal@quickbite.com")!)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(brandOrange)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Terms & Service")
    }
}

struct DividerThin: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.07))
            .frame(height: 0.6)
    }
}

struct SectionBlock: View {
    let number: Int
    let title: String
    let bodyText: String
    var bullets: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(number).")
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }

            Text(bodyText)
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))

            if !bullets.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bullets, id: \.self) { line in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").font(.footnote)
                            Text(line)
                                .font(.footnote)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
    }
}
