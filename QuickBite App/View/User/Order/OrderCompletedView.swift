//
//  OrderCompletedView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI

struct OrderCompletedView: View {

    // MARK: - Dummy Data
    @State private var mealCount: Int = 1
    @State private var mealName: String = "Chicken Katsu Shiokara Ramen"
    @State private var price: Double = 35_000
    @State private var discount: Double = 5_000
    @State private var serviceFee: Double = 2_500
    @State private var total: Double = 32_500
    @State private var orderNumber: String = "000000000000001"
    @State private var orderDate: String = "Fri Oct 24, 2025 10:00 AM"
    @State private var paymentMethod: String = "BCA"

    @State private var restaurantName: String = "Raburi"
    @State private var restaurantCategory: String = "Noodles, Japanese"
    @State private var rating: Double = 4.7
    @State private var reviewCount: Int = 65
    @State private var estTime: String = "10–20 min"

    @State private var pickedTime: String = "Fri Oct 24, 2025 10:30 PM"

    // MARK: Sheet State
    @State private var showPickedDetails = false
    @State private var showReviewView: Bool = false
    @State var userRating: Int
    @State var didSubmitReview: Bool

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    // MARK: - Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completed")
                            .font(.title)
                            .bold()
                        
                        Text("You've picked up the order purchased from this restaurant.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // MARK: - Picked up section
                    VStack(spacing: 0) {
                        HStack {
                            Text("Picked up (\(mealCount))")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Button { showPickedDetails = true
                            } label: {
                                HStack(spacing: 2) {
                                    Text("Details")
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Rectangle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(height: 8)
                        .padding(.vertical, 4)
                    
                    VStack(spacing: 6) {
                        Text("How was your experience?")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)

                        if didSubmitReview == false {
                            // BEFORE submitting review → show tappable stars
                            Button { showReviewView = true } label: {
                                HStack(spacing: 12) {
                                    ForEach(1...5, id: \.self) { i in
                                        Image(systemName: "star")
                                            .font(.title2)
                                            .foregroundColor(Color(.systemGray4))
                                    }
                                }
                            }
                        } else {
                            // AFTER submitting review → show yellow stars
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: i <= userRating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(i <= userRating ? .yellow : Color(.systemGray4))
                                }
                            }
                            .padding(.bottom, 5)
                            .padding(.horizontal)
                        }
                        
                    }
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
                    
                    // MARK: - Order Summary
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text("Order Summary")
                            .font(.subheadline)
                        
                        VStack(spacing: 6) {
                            summaryRow("Quantity", "\(mealCount)")
                            summaryRow("Subtotal", "Rp \(formatPrice(price))")
                            summaryRow("Seller discount", "-Rp \(formatPrice(discount))")
                                .foregroundColor(.green)
                            summaryRow("Service Fee", "+Rp \(formatPrice(serviceFee))")
                            summaryRow("Total", "Rp \(formatPrice(total))")
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        VStack(spacing: 6) {
                            summaryRow("Order number", orderNumber)
                            summaryRow("Order date", orderDate)
                            summaryRow("Payment method", paymentMethod)
                        }
                        .foregroundColor(.secondary)
                        
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // MARK: - Earned Points
                    Text("You've earned 10 points!")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                                        
                    // MARK: - Buttons
                    HStack() {
                        if didSubmitReview == false {
                            Button { showReviewView = true } label: {
                                Text("Write a Review")
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.orange, lineWidth: 1)
                                    )
                            }
                        }
                        
                        Button(action: {}) {
                            Text("Buy Again")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: "#FF9500"))
                                .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationDestination(isPresented: $showReviewView) {
                ReviewView(rating: $userRating, didSubmit: $didSubmitReview)}
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        
        // MARK: - Overlay Sheet Inside Same File
        .sheet(isPresented: $showPickedDetails) {
            VStack(spacing: 0) {
                // Sheet Header
                Text("Pick Up Details")
                    .font(.headline)
                    //.padding(.top, 10)
                    .padding(.bottom, 8)
                
                Divider()
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Picked Up")
                        .font(.subheadline)

                    keyValue("Quantity", "\(mealCount)")
                    keyValue("Seller", restaurantName)
                    keyValue("Time picked up", pickedTime)

                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(22)
        }
    }

    // MARK: Summary Row ViewBuilder
    private func summaryRow(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }

    // MARK: Key Value for Sheet
    private func keyValue(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }
}

#Preview {
    OrderCompletedView(userRating: 0,
                       didSubmitReview: false)
}
