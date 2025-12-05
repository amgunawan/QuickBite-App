//
//  TenantActivityView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI
import Foundation

struct TenantActivityView: View {
    @State private var selectedTab = 0
    @State private var isOpen = true

    let activityTabs = ["New", "Preparing", "Ready", "History"]

    // ===== SAMPLE ORDER DATA =====
    @State var newOrders: [OrderCardViewData] = [
        OrderCardViewData(
            name: "Angela Melia",
            pickupTime: "12:00 PM",
            items: ["2x Chicken Katsu Shirokara Ramen", "1x Cold Ocha"],
            total: "Rp 83.000"
        ),
        OrderCardViewData(
            name: "Natalie Grace",
            pickupTime: "1:20 PM",
            items: ["1x Chicken Katsu Shirokara Ramen", "1x Chicken Katsu Curry Rice"],
            total: "Rp 77.500"
        )
    ]

    @State var preparingOrders: [OrderCardViewData] = [
        OrderCardViewData(
            name: "Rayna Shera",
            pickupTime: "12:00 PM",
            items: ["1x Chicken Teriyaki Shirokara Ramen", "1x Hot Ocha"],
            total: "Rp 46.000"
        )
    ]

    @State var readyOrders: [OrderCardViewData] = []

    @State var historyOrders: [OrderCardViewData] = [
        OrderCardViewData(
            name: "Angela Melia",
            pickupTime: "12:00 PM",
            items: ["2x Chicken Katsu Shirokara Ramen", "1x Cold Ocha"],
            total: "Rp 83.000"
        )
    ]

    // Badge logic
    func badgeCount(_ index: Int) -> Int {
        switch index {
        case 0: return newOrders.count
        case 1: return preparingOrders.count
        case 2: return readyOrders.count
        case 3: return historyOrders.count
        default: return 0
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Activity")
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()

                        Toggle("", isOn: $isOpen)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: UIConst.brandOrange))
                    }
                    .padding(.top, 10)

                    // SEGMENTED CONTROL + BADGES
                    ZStack {
                        Picker("", selection: $selectedTab) {
                            ForEach(0..<activityTabs.count, id: \.self) { i in
                                Text(activityTabs[i]).tag(i)
                            }
                        }
                        .pickerStyle(.segmented)

                        // BADGES
                        HStack {
                            ForEach(0..<activityTabs.count, id: \.self) { i in
                                Spacer()

                                if isOpen && i != 3 && badgeCount(i) > 0 {
                                    Text("\(badgeCount(i))")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(y: -10)
                                        .offset(x: 28)
                                }

                                Spacer()
                            }
                        }
                        .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color.white)

                if !isOpen {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.6))

                        Text("Your restaurant is closed")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("You cannot process orders while closed.")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.bottom, 80)
                    Spacer()

                } else {
                    ScrollView {
                        VStack(spacing: 20) {

                            // NEW
                            if selectedTab == 0 {
                                ForEach(newOrders, id: \.id) { order in
                                    NewOrderCardView(order: order) {
                                        moveToPreparing(order)
                                    }
                                }
                            }

                            // PREPARING
                            if selectedTab == 1 {
                                ForEach(preparingOrders, id: \.id) { order in
                                    PreparingOrderCardView(order: order) {
                                        moveToReady(order)
                                    }
                                }
                            }

                            // READY
                            if selectedTab == 2 {
                                ForEach(readyOrders, id: \.id) { order in
                                    ReadyOrderCardView(order: order)
                                }
                            }

                            // HISTORY
                            if selectedTab == 3 {
                                ForEach(historyOrders, id: \.id) { order in
                                    HistoryOrderCardView(order: order)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    func moveToPreparing(_ order: OrderCardViewData) {
        preparingOrders.append(order)
        newOrders.removeAll { $0.id == order.id }
    }

    func moveToReady(_ order: OrderCardViewData) {
        readyOrders.append(order)
        preparingOrders.removeAll { $0.id == order.id }
    }
}

#Preview {
    TenantActivityView()
}
