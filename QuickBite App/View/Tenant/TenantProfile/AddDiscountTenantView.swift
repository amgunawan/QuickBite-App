//
//  AddDiscountTenantView.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import SwiftUI

struct AddDiscountTenantView: View {
    
    let storeId: String
    var onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddDiscountTenantViewModel()
    
    @State private var discountText: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - MENU PICKER
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Menu")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if vm.isLoadingMenus {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading menu...")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            
                        } else if let err = vm.menuLoadError {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            Text("Menu not available")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            
                        } else {
                            Picker("Menu", selection: $vm.selectedMenuId) {
                                ForEach(vm.menus) { menu in
                                    Text(menu.name)
                                        .tag(menu.itemId)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            
                            Text("Selected: \(vm.selectedMenuName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // MARK: - DISCOUNT AMOUNT
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Discount Amount")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Rp")
                                .foregroundColor(.secondary)
                            
                            TextField("0", text: $discountText)
                                .keyboardType(.numberPad)
                                .onChange(of: discountText) { _, newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    discountText = filtered
                                    vm.discountAmount = Int(filtered) ?? 0
                                }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // MARK: - START DATE
                    HStack(spacing: 20) {
                        Text("Start Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker(
                            "",
                            selection: $vm.startDateTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .padding()
                    }
                    
                    // MARK: - END DATE
                    HStack(spacing: 20) {
                        Text("End Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker(
                            "",
                            selection: $vm.endDateTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .padding()
                    }
                }
                .padding()
            }
            
            // MARK: - SAVE BUTTON
            Button {
                Task {
                    await vm.createDiscount(storeId: storeId)
                    onSave()
                    dismiss()
                }
            } label: {
                Text("Save Discount")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(14)
            }
            .padding()
        }
        .navigationTitle("Create Discount")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.loadMenus(storeId: storeId)
        }
    }
}
