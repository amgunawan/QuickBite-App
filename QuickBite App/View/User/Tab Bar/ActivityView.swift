//
//  ActivityView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct ActivityView: View {

    // MARK: - ENVIRONMENT
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var navState: AppNavigationState

    // MARK: - VIEW MODEL
    @StateObject private var vm = ActivityViewModel()

    // MARK: - UI STATE
    @State private var selectedTab = 0
    @State private var goToPickUpView = false
    @State private var selectedOrderId: String?

    @State private var showReviewView = false
    @State private var selectedOrderIndex: Int?
    @State private var tempRating: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // ================= HEADER =================
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity")
                        .font(.title)
                        .fontWeight(.bold)

                    Picker("", selection: $selectedTab) {
                        Text("History").tag(0)
                        Text("In Progress").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                // ================= CONTENT =================
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // ================= HISTORY =================
                        if selectedTab == 0 {

                            if vm.historyOrders.isEmpty {
                                emptyState("No completed orders yet")
                            }

                            ForEach(vm.historyOrders.indices, id: \.self) { index in
                                let order = vm.historyOrders[index]

                                VStack(spacing: 12) {

                                    headerRow(
                                        date: order.date,
                                        status: "Order Finished",
                                        color: .green
                                    )

                                    orderCard(
                                        order: order,
                                        actionTitle: "Buy Again",
                                        actionEnabled: false,
                                        action: {}
                                    )

                                    if order.rating == nil {
                                        Divider()
                                        ratingRow(index: index)
                                    }
                                }
                                .cardStyle()
                            }
                        }

                        // ================= IN PROGRESS =================
                        else {

                            if vm.progressOrders.isEmpty {
                                emptyState("No ongoing orders")
                            }

                            ForEach(vm.progressOrders) { order in
                                VStack(spacing: 12) {

                                    headerRow(
                                        date: order.date,
                                        status: order.status.capitalized,
                                        color: statusColor(for: order.status)
                                    )

                                    orderCard(
                                        order: order,
                                        actionTitle: "Track Order",
                                        actionEnabled: true
                                    ) {
                                        selectedOrderId = order.id
                                        goToPickUpView = true
                                    }
                                }
                                .cardStyle()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }

            // ================= NAVIGATION =================
            .navigationDestination(isPresented: $goToPickUpView) {
                if let id = selectedOrderId {
                    OrderPreparedView(orderId: id)
                        .navigationBarBackButtonHidden(true)
                }
            }

            .navigationDestination(isPresented: $showReviewView) {
                if let idx = selectedOrderIndex {
                    ReviewView(
                        rating: Binding(
                            get: { tempRating },
                            set: { tempRating = $0 }
                        ),
                        didSubmit: .constant(false),
                        onSubmit: { rating in
                            vm.historyOrders[idx].rating = rating
                        }
                    )
                }
            }

            .onAppear {
                vm.fetchOrders()
                selectedTab = navState.selectedTab
            }
        }
    }

    // ================= ORDER CARD =================
    private func orderCard(
        order: ActivityOrderModel,
        actionTitle: String,
        actionEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {

        HStack(spacing: 12) {

            restaurantImage(
                url: order.restaurantImageURL,
                name: order.restaurantName
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(order.restaurantName ?? "Restaurant")
                    .font(.headline)

                Text(order.mealName ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("Rp\(order.totalCost)")
                    .foregroundColor(.orange)
            }

            Spacer()

            Button(action: action) {
                Text(actionTitle)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            .disabled(!actionEnabled)
        }
    }

    // ================= RESTAURANT IMAGE =================
    private func restaurantImage(
        url: String?,
        name: String?
    ) -> some View {

        ZStack {
            if let urlString = url,
               let imageURL = URL(string: urlString) {

                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        placeholderInitial(name)
                    }
                }
            } else {
                placeholderInitial(name)
            }
        }
        .frame(width: 56, height: 56)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func placeholderInitial(_ name: String?) -> some View {
        Text(name?.prefix(1).uppercased() ?? "?")
            .font(.headline)
            .foregroundColor(.orange)
    }

    // ================= HELPERS =================
    private func headerRow(date: String, status: String, color: Color) -> some View {
        HStack {
            Text(date)
                .foregroundColor(.gray)
            Spacer()
            Text(status)
                .foregroundColor(color)
        }
        .font(.caption)
    }

    private func ratingRow(index: Int) -> some View {
        HStack {
            Text("Give us rating!")
            Spacer()
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: "star.fill")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            tempRating = star
                            selectedOrderIndex = index
                            showReviewView = true
                        }
                }
            }
        }
    }

    private func emptyState(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.gray)
            .padding(.top, 40)
    }

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "ready", "completed":
            return .green
        default:
            return .orange
        }
    }
}

// ================= CARD STYLE =================
private extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2))
            )
    }
}



#Preview {
    ActivityView()
        .environmentObject(CartViewModel())
        .environmentObject(AppNavigationState())
}
