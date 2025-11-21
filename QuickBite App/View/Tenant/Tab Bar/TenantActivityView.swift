//
//  TenantActivityView.swift
//  QuickBite App
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

struct TenantActivityView: View {
    @State private var selectedTab = 0
    
    // Tab Title
    let activityTabs = ["New", "Preparing", "Ready", "History"]
    
    // ====== DATA ORDER (dinamis dari halaman) ======
    var newOrders: [OrderCardViewData] = [
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
    
    var preparingOrders: [OrderCardViewData] = []
    var readyOrders: [OrderCardViewData] = []
    var historyOrders: [OrderCardViewData] = []
    
    // Badge otomatis berdasarkan jumlah array
    func badgeFor(_ index: Int) -> Int {
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
                
                // MARK: HEADER
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    // MARK: SEGMENTED PICKER + BADGE
                    ZStack {
                        Picker("", selection: $selectedTab) {
                            ForEach(0..<activityTabs.count, id: \.self) { index in
                                Text(activityTabs[index]).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        // BADGE overlay agar tetap segmented tapi ada badge
                        HStack {
                            ForEach(0..<activityTabs.count, id: \.self) { index in
                                Spacer()
                                
                                ZStack {
                                    if badgeFor(index) > 0 {
                                        Text("\(badgeFor(index))")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(y: -10)
                                            .offset(x: 30)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .allowsHitTesting(false) // supaya badge tidak ganggu klik picker
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray5)),
                    alignment: .bottom
                )
                
                // MARK: CONTENT
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // == NEW ORDERS ==
                        if selectedTab == 0 {
                            ForEach(newOrders, id: \.id) { order in
                                OrderCardView(
                                    name: order.name,
                                    pickupTime: order.pickupTime,
                                    items: order.items,
                                    total: order.total
                                )
                            }
                        }
                        
                        // == PREPARING ==
                        if selectedTab == 1 {
                            Text("Preparing orders here...")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        }
                        
                        // == READY ==
                        if selectedTab == 2 {
                            Text("Ready orders here...")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        }
                        
                        // == HISTORY ==
                        if selectedTab == 3 {
                            Text("History orders here...")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// ===== DATA MODEL =====
struct OrderCardViewData: Identifiable {
    let id = UUID()
    let name: String
    let pickupTime: String
    let items: [String]
    let total: String
}

// ===== CARD (TIDAK DIUBAH) =====
struct OrderCardView: View {
    let name: String
    let pickupTime: String
    let items: [String]
    let total: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text("Pick up at \(pickupTime)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.subheadline)
            }

            Divider()

            Text("Total: \(total)")
                .fontWeight(.bold)

            Divider()

            HStack {
                Button(action: {}) {
                    Text("Reject")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(52)
                }

                Button(action: {}) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(52)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5))
                .background(Color.white.cornerRadius(16))
        )
    }
}

#Preview {
    TenantActivityView()
}
