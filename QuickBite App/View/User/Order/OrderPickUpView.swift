//
//  OrderPickUpView.swift
//  QuickBite
//
//  Created by student on 26/11/25
//

import SwiftUI

// MARK: - MODEL
struct OrderedItemPU: Identifiable {
    let id = UUID()
    let count: Int
    let name: String
    let price: Double
}

// MARK: - VIEW
struct OrderPickUpView: View {

    // DATA DARI ORDER CONFIRMATION
    let qrImage: UIImage?
    let orderId: String

    // DUMMY DATA (BISA DIGANTI DATA ASLI NANTI)
    @State private var items: [OrderedItemPU] = [
        OrderedItemPU(count: 1, name: "Chicken Katsu Shirokara Ramen", price: 35000),
        OrderedItemPU(count: 1, name: "Chicken Teriyaki Donburi", price: 42000)
    ]

    @State private var discount: Double = 5_000
    @State private var serviceFee: Double = 2_500
    @State private var orderNumber: String = "000000000000001"
    @State private var orderDate: String = "Fri Oct 24, 2025 10:00 AM"
    @State private var expireDate: String = "Fri Oct 24, 2025 5:00 PM"
    @State private var paymentMethod: String = "BCA"

    @State private var restaurantName: String = "Raburi"
    @State private var restaurantCategory: String = "Noodles, Japanese"
    @State private var rating: Double = 4.7
    @State private var reviewCount: Int = 65
    @State private var estTime: String = "10–20 min"

    // MARK: - COMPUTED
    private var totalMealCount: Int {
        items.reduce(0) { $0 + $1.count }
    }

    private var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.count)) }
    }

    private var total: Double {
        subtotal - discount + serviceFee
    }

    // MARK: - BODY
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {

                // HEADER
                VStack(alignment: .leading) {
                    Text("\(totalMealCount) meal to pick up")
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("Expires on \(expireDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Divider()

                // QR SECTION
                VStack(spacing: 10) {
                    Text("Scan QR at Restaurant")
                        .font(.headline)

                    if let qrImage {
                        Image(uiImage: qrImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                    } else {
                        ProgressView("Generating QR...")
                    }

                    Text("Order ID: \(orderId)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("Take a screenshot of this QR code to pick up your meal when the network is poor.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding()

                Divider()

                // ORDER SUMMARY
                VStack(alignment: .leading, spacing: 6) {
                    Text("Order Summary")
                        .font(.subheadline)

                    SummaryRow(title: "Quantity", value: "\(totalMealCount)")
                    SummaryRow(title: "Subtotal", value: "Rp\(formatPrice(subtotal))")

                    SummaryRow(
                        title: "Seller discount",
                        value: "-Rp\(formatPrice(discount))",
                        valueColor: .green
                    )

                    SummaryRow(
                        title: "Service Fee",
                        value: "+Rp\(formatPrice(serviceFee))"
                    )

                    SummaryRow(
                        title: "Total",
                        value: "Rp\(formatPrice(total))",
                        weight: .semibold
                    )
                }
                .padding(.horizontal)

                Divider()

                // ORDER INFO
                VStack(spacing: 6) {
                    SummaryRow(title: "Order number", value: orderNumber)
                    SummaryRow(title: "Order date", value: orderDate)
                    SummaryRow(title: "Payment method", value: paymentMethod)
                }
                .foregroundColor(.secondary)
                .padding(.horizontal)

                // BUY AGAIN BUTTON
                Button(action: {
                    // TODO: Navigate to home / reorder
                }) {
                    Text("Buy Again")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(24)
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - PREVIEW
#Preview {
    OrderPickUpView(
        qrImage: UIImage(systemName: "qrcode"),
        orderId: "QB12345ABCDE"
    )
}
