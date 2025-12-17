//
//  FinancialPayoutsView.swift
//  QuickBite App
//
//  Created by jessica tedja on 05/11/25.
//

import SwiftUI
import Foundation

struct FinancialPayoutsTenantView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = FinancialPayoutsViewModel(storeId: "2plb4UCwxjle2Yy6PTdj")
    
    private let bankOptions = [
        "Bank Central Asia (BCA)",
        "Bank Mandiri",
        "Bank Negara Indonesia (BNI)",
        "Bank Rakyat Indonesia (BRI)",
        "Bank CIMB Niaga",
        "Bank Danamon",
        "Bank Permata",
        "Bank Panin",
        "Bank Maybank Indonesia",
        "Bank OCBC NISP",
        "Bank Jago"
    ]
    
    @State private var showBankPicker = false
    
    private var isValid: Bool {
        !vm.bankName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !vm.accountHolder.trimmingCharacters(in: .whitespaces).isEmpty &&
        !vm.accountNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !vm.nmid.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bank Account Details")
                        .font(.title3).bold()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bank Name").font(.subheadline).foregroundColor(.secondary)
                        
                        Button {
                            showBankPicker = true
                        } label: {
                            HStack {
                                Text(vm.bankName.isEmpty ? "Select bank" : vm.bankName)
                                    .foregroundColor(vm.bankName.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color(.secondarySystemBackground),
                                        in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Account Holder Name").font(.subheadline).foregroundColor(.secondary)
                        TextField(
                            "Enter account holder name",
                            text: $vm.accountHolder
                        )
                        .onChange(of: vm.accountHolder) { _ in
                            vm.markDirty()
                        }
                        .fieldStyle()
                        Text("Account holder name must match the name on KTP uploaded")
                            .font(.footnote).foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Account Number").font(.subheadline).foregroundColor(.secondary)
                        TextField(
                            "Enter account number",
                            text: $vm.accountNumber
                        )
                        .keyboardType(.numberPad)
                        .onChange(of: vm.accountNumber) { newValue in
                            vm.numericAccountOnly(newValue)
                        }
                        .fieldStyle()
                    }
                    
                    Divider().padding(.top, 4)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("QRIS")
                        .font(.title3).bold()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NMID (National Merchant ID)").font(.subheadline).foregroundColor(.secondary)
                        TextField("Enter NMID", text: $vm.nmid)
                            .onChange(of: vm.nmid) { _ in
                                vm.markDirty()
                            }
                            .fieldStyle()
                        Text("This is required for integrated digital payments. It should be provided by your QRIS provider.")
                            .font(.footnote).foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                vm.fetchPayoutDetails()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Financial & Payouts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        
        VStack(spacing: 0) {
            Button {
                vm.savePayoutDetails {
                    dismiss()
                }
            } label: {
                Text("Save Changes")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(vm.isDirty && vm.isValid
                                ? Color.orange
                                : Color.orange.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24)) // Corner radius disesuaikan agar lebih modern
            }
            .disabled(!(vm.isDirty && vm.isValid))
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        
        .sheet(isPresented: $showBankPicker) {
            VStack(spacing: 4) {
                HStack {
                    Text("Select Bank").font(.headline)
                    Spacer()
                    Button("Close") { showBankPicker = false }
                        .foregroundColor(.orange).font(.headline)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 10)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(bankOptions, id: \.self) { bank in
                            Button {
                                vm.bankName = bank
                                vm.markDirty()
                                showBankPicker = false
                            } label: {
                                HStack {
                                    Text(bank)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                            
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.50)])
            .presentationDragIndicator(.visible)
        }
    }
}

private extension View {
    func fieldStyle() -> some View {
        self
            .padding(12)
            .background(Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private extension Binding where Value == String {
    func onChange(_ handler: @escaping () -> Void) -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { newVal in
                wrappedValue = newVal
                handler()
            }
        )
    }
}
