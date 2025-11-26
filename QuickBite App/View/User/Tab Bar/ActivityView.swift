//
//  ActivityView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct ActivityView: View {

    // MARK: - History Orders
    @State private var historyOrders: [ActivityOrderModel] = [
        ActivityOrderModel(date: "24 Okt, 13:00",
                           restaurantName: "Raburi",
                           mealName: "1 Chicken Katsu Shirokara Ramen",
                           price: 32500,
                           rating: nil),          // belum rating

        ActivityOrderModel(date: "24 Okt, 13:00",
                           restaurantName: "Raburi",
                           mealName: "1 Chicken Katsu Shirokara Ramen",
                           price: 32500,
                           rating: 4),            // sudah rating

        ActivityOrderModel(date: "24 Okt, 13:00",
                           restaurantName: "Raburi",
                           mealName: "1 Chicken Katsu Shirokara Ramen",
                           price: 32500,
                           rating: 5)             // sudah rating
    ]

    // MARK: - In Progress Orders
    @State private var progressOrders: [InProgressOrderModel] = [
        InProgressOrderModel(date: "25 Okt, 16:00",
                             restaurantName: "Kaya Boys",
                             mealName: "1 Kaya Sandwiches",
                             price: 15000,
                             isReady: false),      // Ready in X

        InProgressOrderModel(date: "25 Okt, 16:00",
                             restaurantName: "Kaya Boys",
                             mealName: "1 Kaya Sandwiches",
                             price: 15000,
                             isReady: true)        // Pick Up Available
    ]

    // MARK: - States
    @State private var selectedTab = 0
    @State private var goToPreparedView = false
    @State private var goToPickUpView = false

    // Review navigation state
    @State private var showReviewView = false
    @State private var selectedOrderIndex: Int? = nil
    @State private var tempRating: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // HEADER
                VStack(spacing: 12) {
                    Text("Activity")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Picker("", selection: $selectedTab) {
                        Text("History").tag(0)
                        Text("In Progress").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 16) {

                        // MARK: - HISTORY TAB
                        if selectedTab == 0 {

                            ForEach(historyOrders.indices, id: \.self) { index in
                                let order = historyOrders[index]

                                VStack(spacing: 16) {

                                    // Date & Status
                                    HStack {
                                        Text(order.date)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        Spacer()

                                        Text("Order Finished")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.green)
                                    }

                                    // CARD → clickable only if SUDAH rating
                                    if order.rating != nil {
                                        NavigationLink(
                                            destination: OrderCompletedView(userRating: order.rating ?? 0,
                                                                            didSubmitReview: order.rating != nil)
                                                .onAppear {
                                                    // kirim rating ke halaman completed
                                                    // nanti kamu isi logicnya
                                                }
                                        ) {
                                            orderCard(order: order)
                                        }
                                        .foregroundColor(.primary)
                                    } else {
                                        // Belum rating → non clickable card
                                        orderCard(order: order)
                                    }

                                    // MARK: - GIVE US RATING SECTION
                                    if order.rating == nil {

                                        Divider()

                                        HStack {
                                            Text("Give us rating!")
                                                .font(.subheadline)

                                            Spacer()

                                            HStack(spacing: 6) {
                                                ForEach(1...5, id: \.self) { star in
                                                    Image(systemName: "star.fill")
                                                        .foregroundColor(Color(.systemGray4))
                                                        .onTapGesture {
                                                            // buka review view
                                                            tempRating = star
                                                            selectedOrderIndex = index
                                                            showReviewView = true
                                                        }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray5))
                                )
                            }
                        }

                        // MARK: - IN PROGRESS TAB
                        else {
                            ForEach(progressOrders.indices, id: \.self) { index in
                                let order = progressOrders[index]

                                VStack(spacing: 16) {

                                    HStack {
                                        Text(order.date)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        Spacer()

                                        if !order.isReady {
                                            HStack(spacing: 4) {
                                                Text("Ready in:")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Text("10 minutes")
                                                    .foregroundColor(.orange)
                                            }
                                        } else {
                                            Text("Pick Up Available")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.green)
                                        }
                                    }

                                    HStack(spacing: 12) {
                                        Image("KayaBoys")
                                            .resizable()
                                            .frame(width: 64, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(order.restaurantName)
                                                .font(.headline)
                                                .fontWeight(.bold)

                                            Text(order.mealName)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)

                                            Text("Rp\(order.price)")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.orange)
                                        }

                                        Spacer()

                                        Button {
                                            if order.isReady {
                                                goToPickUpView = true
                                            } else {
                                                goToPreparedView = true
                                            }
                                        } label: {
                                            Text("Track Order")
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.orange)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray5))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }

            // MARK: DESTINATIONS
            .navigationDestination(isPresented: $goToPreparedView) {
                OrderPreparedView()
            }
            .navigationDestination(isPresented: $goToPickUpView) {
                OrderPickUpView()
            }
            .navigationDestination(isPresented: $showReviewView) {
                if let idx = selectedOrderIndex {
                    ReviewView(
                        rating: Binding(
                            get: { tempRating },
                            set: { tempRating = $0 }
                        ),
                        didSubmit: Binding(
                            get: { historyOrders[idx].rating != nil },
                            set: { _ in }
                        ),
                        onSubmit: { finalRating in
                            historyOrders[idx].rating = finalRating
                        }
                    )
                }
            }
        }
    }

    // MARK: - ORDER CARD VIEW
    private func orderCard(order: ActivityOrderModel) -> some View {
        HStack(spacing: 12) {
            Image("Raburi")
                .resizable()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(order.restaurantName)
                    .font(.headline)
                    .fontWeight(.bold)

                Text(order.mealName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("Rp\(order.price)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }

            Spacer()

            Button(action: {}) {
                Text("Buy Again")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
    }
    
}


#Preview {
    ActivityView()
}
