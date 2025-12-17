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
    
    let activityTabs = ["Preparing", "Ready", "History"]
    
    // Badge logic
    func badgeCount(_ index: Int) -> Int {
        switch index {
        case 0: return vm.preparingOrders.count
        case 1: return vm.readyOrders.count
        case 2: return vm.historyOrders.count
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // NEW
                        if selectedTab == 0 {
                            VStack(spacing: 16) {
                                ForEach(vm.preparingOrders) { order in
                                    PreparingOrderCardView(order: order) {
                                        Task {
                                            // Update ke Firestore
                                            await vm.updateStatus(orderId: order.id, to: "ready")
                                            
                                            // Pindah ke tab History
                                            withAnimation {
                                                selectedTab = 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // READY
                        if selectedTab == 1 {
                            VStack(spacing: 16) {
                                ForEach(vm.readyOrders) { order in
                                    ReadyOrderCardView(order: order) {
                                        Task {
                                            // Update ke Firestore
                                            await vm.updateStatus(orderId: order.id, to: "completed")
                                            
                                            // Pindah ke tab History
                                            withAnimation {
                                                selectedTab = 2
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // HISTORY
                        if selectedTab == 2 {
                            VStack(spacing: 16) {
                                ForEach(vm.historyOrders) { order in
                                    
                                    HistoryOrderCardView(order: order)
                                }
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
