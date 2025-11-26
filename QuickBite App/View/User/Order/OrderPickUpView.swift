//
//  OrderPickUpView.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI

struct OrderPickUpView: View {
    // MARK: - States (Dummy Data)
    @State private var mealCount: Int = 1
    @State private var mealName: String = "Chicken Katsu Shirokara Ramen"
    @State private var price: Double = 35_000
    @State private var discount: Double = 5_000
    @State private var serviceFee: Double = 2_500
    @State private var total: Double = 32_500
    @State private var orderNumber: String = "000000000000001"
    @State private var orderDate: String = "Fri Oct 24, 2025 10:00 AM"
    @State private var expireDate: String = "Fri Oct 24, 2025 5:00 PM"
    @State private var paymentMethod: String = "BCA"
    @State private var restaurantName: String = "Raburi"
    @State private var restaurantCategory: String = "Noodles, Japanese"
    @State private var rating: Double = 4.7
    @State private var reviewCount: Int = 65
    @State private var estTime: String = "10–20 min"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                // MARK: - Title Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(mealCount) meal to pick up")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Expires on \(expireDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical, 4)

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
                

                // MARK: - Order Details
                VStack(spacing: 6) {
                    HStack {
                        Text("Order Details")
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("\(mealCount)x ")
                            .font(.headline)
                        Text("\(mealName)")
                            .font(.headline).fontWeight(.regular)
                        Spacer()
                        Text("Rp\(formatPrice(price))")
                            .font(.headline).fontWeight(.regular)
                    }
                    .padding(.horizontal)
                }
                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(height: 8)
                    .padding(.vertical, 4)

                // MARK: - Order Pick Up Section
                VStack(spacing: 6) {
                    Text("Scan QR at Restaurant")
                        .font(.headline)
                    Image("PickUpQR")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.top, 6)
                    Text("Take a screenshot of this QR code to pick up\nyour meal when the network is poor.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                Rectangle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(height: 8)
                    .padding(.vertical, 4)
              
                // MARK: - Restaurant Info
                VStack(alignment: .leading, spacing: 6) {
                    Text("Restaurant Info")
                        .font(.subheadline)
                    HStack(alignment: .center, spacing: 12) {
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
                                    .font(.caption)
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

                // MARK: - Things to Note
                VStack(alignment: .leading, spacing: 6) {
                    Text("Things to Note")
                        .font(.subheadline)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Expires within 5 hours of purchase")
                                    .font(.subheadline).fontWeight(.semibold)
                                Text("Pick up this order within 5 hours of purchase")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Pick up hours")
                                    .font(.subheadline).fontWeight(.semibold)
                                Text("Pick up during restaurant’s operating hours")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
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
                        SummaryRow(title: "Quantity", value: "\(mealCount)")
                        SummaryRow(title: "Subtotal", value: "Rp\(formatPrice(price))")

                        SummaryRow(title: "Seller discount",
                            value:"-Rp\(formatPrice(discount))",
                            valueColor: .green)

                        SummaryRow(title: "Service Fee", value:"+Rp\(formatPrice(serviceFee))")

                        SummaryRow(title: "Total",
                            value:"Rp\(formatPrice(total))",
                            weight: .semibold)
                    }

                    Divider().padding(.vertical, 4)

                    VStack(spacing: 6) {
                        SummaryRow(title: "Order number", value: orderNumber)
                        SummaryRow(title: "Order date", value: orderDate)
                        SummaryRow(title: "Payment method", value: paymentMethod)
                                       }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

                // MARK: - Buy Again Button
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
    OrderPickUpView()
}
