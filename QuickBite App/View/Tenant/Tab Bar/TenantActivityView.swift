//
//  TenantActivityView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI
import Foundation

struct TenantActivityView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    private var storeId: String? {
        authVM.currentUserSession?.storeId
    }
    
    @StateObject private var vm = TenantActivityViewModel()
    
    @State private var selectedTab = 0
    @State private var isOpen = true
    
    let activityTabs = ["New", "Preparing", "Ready", "History"]
    
    // Badge logic
    func badgeCount(_ index: Int) -> Int {
        switch index {
        case 0: return vm.newOrders.count
        case 1: return vm.preparingOrders.count
        case 2: return vm.readyOrders.count
        case 3: return vm.historyOrders.count
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
                
                //                if !isOpen {
                //                    Spacer()
                //                    VStack(spacing: 12) {
                //                        Image(systemName: "lock.fill")
                //                            .font(.system(size: 40))
                //                            .foregroundColor(.gray.opacity(0.6))
                //
                //                        Text("Your restaurant is closed")
                //                            .font(.headline)
                //                            .foregroundColor(.gray)
                //
                //                        Text("You cannot process orders while closed.")
                //                            .font(.subheadline)
                //                            .foregroundColor(.gray.opacity(0.7))
                //                    }
                //                    .padding(.bottom, 80)
                //                    Spacer()
                //
                //                } else {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // NEW
                        if selectedTab == 0 {
                            ForEach(vm.newOrders) { order in
                                NewOrderCardView(order: order) {
                                    vm.updateStatus(
                                        orderId: order.id,
                                        to: "preparing"
                                    )
                                }
                            }
                        }
                        
                        // PREPARING
                        if selectedTab == 1 {
                            ForEach(vm.preparingOrders) { order in
                                PreparingOrderCardView(order: order) {
                                    vm.updateStatus(
                                        orderId: order.id,
                                        to: "ready_for_pickup"
                                    )
                                }
                            }
                        }
                        
                        
                        // READY
                        if selectedTab == 2 {
                            ForEach(vm.readyOrders) { order in
                                ReadyOrderCardView(order: order)
                            }
                        }
                        
                        // HISTORY
                        if selectedTab == 3 {
                            ForEach(vm.historyOrders) { order in
                                HistoryOrderCardView(order: order)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }
            .onAppear {
                if let storeId = authVM.currentUserSession?.storeId {
                    vm.startListening(storeId: storeId)
                }
            }
            .onDisappear {
                vm.stopListening()
            }
        }
    }
}

#Preview {
    TenantActivityView()
}
