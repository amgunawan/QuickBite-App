//
//  DiscountListTenantView.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import SwiftUI

struct DiscountListTenantView: View {
    
    let storeId: String
    @StateObject private var vm = DiscountListTenantViewModel()
    @State private var showAddDiscount = false
    
    var body: some View {
        VStack {
            if vm.isLoading || !vm.isMenuLoaded {
                ProgressView("Loading discounts...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

            } else {
                if vm.discounts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tag")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No discounts yet")
                            .foregroundColor(.secondary)
                    }
                    .padding()

                } else {
                    List {
                        ForEach(Array(vm.discounts.enumerated()), id: \.element.id) { index, discount in
                            DiscountRow(
                                discount: discount,
                                menuName: vm.menuNameMap[discount.itemId] ?? "-"
                            )
                            // Cek jika ini adalah indeks 0 (baris pertama)
                            .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                        }
                    }
                    .listStyle(.plain)
                }
                
                // CREATE BUTTON
                Button {
                    showAddDiscount = true
                } label: {
                    Text("Create Discount")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(24)
                }
                .padding(.horizontal)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .scrollContentBackground(.hidden)
        .navigationTitle("Discounts")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.loadDiscounts(storeId: storeId)
            vm.loadMenuNames(storeId: storeId)   // 👈 TAMBAH INI
        }
        .sheet(isPresented: $showAddDiscount) {
            NavigationStack {
                AddDiscountTenantView(storeId: storeId) {
                    vm.loadDiscounts(storeId: storeId)
                }
            }
        }
    }
}

struct DiscountRow: View {
    let discount: DiscountModel
    let menuName: String
    
    var statusText: String {
        if discount.isActive { return "Active" }
        if Date() < discount.startDateTime { return "Upcoming" }
        return "Expired"
    }
    
    var statusColor: Color {
        if discount.isActive { return .green }
        if Date() < discount.startDateTime { return .orange }
        return .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Menu: \(menuName)")   // ✅ BUKAN Menu ID
                    .font(.headline)
                
                Spacer()
                
                Text(statusText)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Text("Discount: Rp \(discount.amount)")
                .font(.subheadline)
            
            Text(
                "\(discount.startDateTime.formatted(date: .abbreviated, time: .shortened))"
                + " → "
                + "\(discount.endDateTime.formatted(date: .abbreviated, time: .shortened))"
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}



