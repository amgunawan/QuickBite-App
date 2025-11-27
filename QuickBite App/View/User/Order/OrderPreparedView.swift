//
//  OrderPreparedView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI

// MARK: - MODEL FOR ORDERED ITEMS
struct OrderedItem: Identifiable {
    let id = UUID()
    let count: Int
    let name: String
    let price: Double
}

struct OrderPreparedView: View {

    // MARK: - Dummy Order Items (You can replace with real data)
    @State private var items: [OrderedItem] = [
        OrderedItem(count: 1, name: "Chicken Katsu Shirokara Ramen", price: 35000),
        OrderedItem(count: 1, name: "Chicken Teriyaki Donburi", price: 42000)
    ]

    // MARK: - Other States (Dummy Data)
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

    // MARK: - Computed totals
    private var totalMealCount: Int {
        items.reduce(0) { $0 + $1.count }
    }

    private var subtotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.count)) }
    }

    private var total: Double {
        subtotal - discount + serviceFee
    }

    var body: some View {
        ScrollView(showsIndicators: false) {

            VStack(alignment: .leading) {

                // MARK: - Title
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(totalMealCount) meal to pick up")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Expires on \(expireDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Divider().padding(.vertical, 4)

                // MARK: - Reminder Banner
                HStack(spacing: 8) {
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(Color(hex: "#FF9500"))
                    Text("Visit the restaurant to pick up your order")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#FF9500"))
                }
                .padding(.horizontal)

                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(height: 8)
                    .padding(.vertical, 4)


                // MARK: - ORDER DETAILS (UPDATED)
                VStack(spacing: 6) {

                    HStack {
                        Text("Order Details")
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal)

                    VStack(spacing: 6) {
                        ForEach(items) { item in
                            HStack {
                                Text("\(item.count)x")
                                    .font(.headline)

                                Text(item.name)
                                    .font(.headline)
                                    .fontWeight(.regular)

                                Spacer()

                                Text("Rp\(formatPrice(item.price))")
                                    .font(.headline).fontWeight(.regular)
                            }
                        }
                    }
                    .padding(.horizontal)

                }

                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(height: 8)
                    .padding(.vertical, 4)


                // MARK: - Order in Preparation
                VStack(spacing: 6) {
                    Text("Order in Preparation")
                        .font(.headline)

                    Image("Prepared")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.top, 6)

                    Text("The restaurant is preparing your order.\nThe QR code will appear when it’s ready.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(height: 8)
                    .padding(.vertical, 4)


                // MARK: - Restaurant Info
                VStack(alignment: .leading, spacing: 6) {

                    Text("Restaurant Info")
                        .font(.subheadline)

                    HStack(spacing: 12) {

                        Image("Raburi")
                            .resizable()
                            .cornerRadius(8)
                            .frame(width: 62, height: 62)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurantName)
                                .font(.headline)
                            Text(restaurantCategory)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(String(format: "%.1f", rating)) (\(reviewCount)) • \(estTime)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                }
                .padding(.horizontal)

                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(height: 8)
                    .padding(.vertical, 4)


                // MARK: - Order Summary
                VStack(alignment: .leading, spacing: 6) {

                    Text("Order Summary")
                        .font(.subheadline)

                    VStack(spacing: 6) {

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

                    Divider().padding(.vertical, 4)

                    VStack(spacing: 6) {
                        SummaryRow(title: "Order number", value: orderNumber)
                        SummaryRow(title: "Order date", value: orderDate)
                        SummaryRow(title: "Payment method", value: paymentMethod)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)


                // MARK: - BUY AGAIN BUTTON
                Button(action: {}) {
                    Text("Buy Again")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#FF9500"))
                        .cornerRadius(24)
                }
                .padding(.horizontal)

            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    OrderPreparedView()
}
