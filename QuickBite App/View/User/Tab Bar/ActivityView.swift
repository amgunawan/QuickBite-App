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

    // MARK: - VIEW MODEL
    @StateObject private var vm = ActivityViewModel()

    // MARK: - UI STATE
    @State private var selectedTab = 0
    @State private var goToPickUpView = false
    @State private var selectedOrderId: String?
    @State private var generatedQR: UIImage?

    @State private var showReviewView = false
    @State private var selectedOrderIndex: Int?
    @State private var tempRating: Int = 0

    @State private var goToCart = false

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

                        // ---------- HISTORY ----------
                        if selectedTab == 0 {

                            if vm.historyOrders.isEmpty {
                                emptyState("No completed orders yet")
                            }

                            ForEach(vm.historyOrders.indices, id: \.self) { index in
                                let order = vm.historyOrders[index]

                                VStack(spacing: 16) {

                                    HStack {
                                        Text(order.date)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("Order Finished")
                                            .foregroundColor(.green)
                                    }

                                    orderCard(order: order)

                                    // Rating
                                    if order.rating == nil {
                                        Divider()
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
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.gray.opacity(0.2))
                                )
                            }
                        }

                        // ---------- IN PROGRESS ----------
                        else {

                            if vm.progressOrders.isEmpty {
                                emptyState("No ongoing orders")
                            }

                            ForEach(vm.progressOrders) { order in
                                VStack(spacing: 16) {

                                    HStack {
                                        Text(order.date)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("Preparing")
                                            .foregroundColor(.orange)
                                    }

                                    HStack(spacing: 12) {

                                        Image(systemName: "bag.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(.orange)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(order.restaurantName ?? "Restaurant")
                                                .font(.headline)

                                            Text(order.mealName ?? order.itemId)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)

                                            Text("Rp\(order.totalCost)")
                                                .foregroundColor(.orange)
                                        }

                                        Spacer()

                                        Button {
                                            selectedOrderId = order.orderId
                                            generatedQR = QRGenerator().generate(from: order.orderId)
                                            goToPickUpView = true
                                        } label: {
                                            Text("Track Order")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.orange)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.gray.opacity(0.2))
                                )
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
                    OrderPickUpView(
                        qrImage: generatedQR,
                        orderId: id
                    )
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

            .fullScreenCover(isPresented: $goToCart) {
                NavigationStack {
                    CartListView()
                        .environmentObject(cart)
                }
            }

            .onAppear {
                vm.fetchOrders()
            }
        }
    }

    // ================= HELPER =================
    private func emptyState(_ text: String) -> some View {
        VStack {
            Text(text)
                .foregroundColor(.gray)
                .padding(.top, 40)
        }
    }

    // ================= BUY AGAIN =================
//    private func handleBuyAgain(_ order: ActivityOrderModel) {
//
//        let newItem = CartItemModel(
//            name: order.mealName ?? order.itemId,
//            imageName: "",
//            basePrice: Double(order.price),
//            baseOriginalPrice: nil,
//            quantity: order.quantity,
//            note: "",
//            noodleType: "",
//            level: "",
//            topping: "",
//            optionsPrice: 0
//        )
//
//        cart.add(item: newItem)
//        goToCart = true
//    }

    // ================= ORDER CARD =================
    private func orderCard(order: ActivityOrderModel) -> some View {
        HStack(spacing: 12) {

            Image(systemName: "bag.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(order.restaurantName ?? "Restaurant")
                    .font(.headline)

                Text(order.mealName ?? order.itemId)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("Rp\(order.totalCost)")
                    .foregroundColor(.orange)
            }

            Spacer()

            Button {} label: {
                Text("Buy Again")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            .disabled(true)

        }
    }
}

#Preview {
    ActivityView()
        .environmentObject(CartViewModel())
}
