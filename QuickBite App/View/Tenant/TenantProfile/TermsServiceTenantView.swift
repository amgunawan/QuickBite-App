import SwiftUI

struct TermsServiceTenantView: View {
    private let brandOrange = Color(red: 1.0, green: 0.584, blue: 0.0)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Header note
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last updated: November 5, 2025")
                        .font(.footnote)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Text("Please read these terms and conditions carefully before using our service.")
                        .font(.footnote)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
                .padding(.top, 2)

                DividerThin()

                // 1. Merchant Responsibility & Service Quality
                SectionBlock(
                    number: 1,
                    title: "Merchant Responsibility & Service Quality",
                    bodyText: "",
                    bullets: [
                        "Accuracy: You are responsible for ensuring your menu, pricing, preparation times, and stock availability (including \"Out of Stock\" status) are always current and accurate in the QuickBite app.",
                        "Fulfillment: All accepted orders must be fulfilled accurately and delivered to the customer at the agreed-upon campus pickup location within the promised time window.",
                        "Hygiene & Safety: You must adhere to all applicable health, hygiene, and food safety standards and regulations."
                    ]
                )

                DividerThin()

                // 2. Financial Terms
                SectionBlock(
                    number: 2,
                    title: "Financial Terms",
                    bodyText: "",
                    bullets: [
                        "Pricing: You determine the final price of all menu items.",
                        "Fees: QuickBite will deduct a pre-agreed service fee (commission) from the total order value before payout.",
                        "Payouts: Payments will be processed daily according to the schedule outlined in the FAQ and Financials section of the app."
                    ]
                )

                DividerThin()

                // 3. Order Management
                SectionBlock(
                    number: 3,
                    title: "Order Management",
                    bodyText: "",
                    bullets: [
                        "Acceptance: You commit to promptly accepting or rejecting new orders via the app. Unattended orders may be automatically cancelled.",
                        "Cancellations: If an order must be cancelled after acceptance (e.g., due to an emergency shortage), you must process an immediate, full refund to the customer and notify them promptly."
                    ]
                )

                DividerThin()

                // 4. Termination
                SectionBlock(
                    number: 4,
                    title: "Termination",
                    bodyText:
"""
QuickBite reserves the right to suspend or terminate your access to the platform immediately if you breach these terms (e.g., repeated failure to fulfill orders, severe inaccuracies, or safety violations). You may terminate this agreement at any time by notifying us.
"""
                )

                // Contact
                VStack(alignment: .leading, spacing: 6) {
                    Text("If you have any questions about these Terms, please contact us at")
                        .font(.footnote)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Link("legal@quickbite.com",
                         destination: URL(string: "mailto:legal@quickbite.com")!)
                        .font(.footnote.weight(.semibold))
                        .tint(brandOrange)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("Terms & Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension TermsServiceTenantView {
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

                if !bodyText.isEmpty {
                    Text(bodyText)
                        .font(.footnote)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }

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
                    .padding(.top, bodyText.isEmpty ? 0 : 2)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { TermsServiceTenantView() }
}
