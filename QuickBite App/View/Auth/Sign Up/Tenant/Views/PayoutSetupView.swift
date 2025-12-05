//
//  PayoutSetupView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct PayoutSetupView: View {
    @EnvironmentObject var storeVM: StoreRegistrationViewModel
    
    @State private var showBankPicker = false
    
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
        "Bank OCBC NISP"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            
            RegistrationHeader(step: 3,
                               title: "Payout & QRIS Setup",
                               subtitle: "Please provide your bank details for daily payouts and your QRIS identifier")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // =========================
                    // BANK ACCOUNT DETAILS
                    // =========================
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Bank Account Details")
                            .font(.title3).bold()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bank Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                showBankPicker = true
                            } label: {
                                HStack {
                                    Text(storeVM.payoutBankName.isEmpty ? "Select bank" : storeVM.payoutBankName)
                                        .foregroundColor(storeVM.payoutBankName.isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding(12)
                                .background(Color(.secondarySystemBackground),
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Account Holder Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter account holder name", text: $storeVM.payoutAccountHolder)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .fieldStyle()
                            
                            Text("Account holder name must match the name on KTP uploaded")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Account Number")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter account number", text: $storeVM.payoutAccountNumber)
                                .keyboardType(.numberPad)
                                .fieldStyle()
                        }
                        
                        Divider().padding(.top, 6)
                    }
                    
                    // =========================
                    // QRIS SECTION
                    // =========================
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QRIS")
                            .font(.title3).bold()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NMID (National Merchant ID)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter NMID", text: $storeVM.payoutNMID)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.asciiCapable)
                                .fieldStyle()
                            
                            Text("This is required for integrated digital payments. It should be provided by your QRIS provider.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            
            // ✅ BUTTON — NOT MODIFIED
            NavigationLink(
                destination: ConfirmationView(
                    setupAction: { }
                ),
                label: {
                    OrangeButton(title: "Complete Registration", enabled: canComplete)
                }
            )
            .padding()
            .simultaneousGesture(TapGesture().onEnded {
                hideKeyboard()
            })
        }
        // ✅ BANK PICKER SHEET
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
                                storeVM.payoutBankName = bank
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
    
    // ✅ VALIDATION (UNCHANGED)
    private var canComplete: Bool {
        !storeVM.payoutBankName.isEmpty &&
        !storeVM.payoutAccountHolder.isEmpty &&
        !storeVM.payoutAccountNumber.isEmpty &&
        !storeVM.payoutNMID.isEmpty &&
        storeVM.payoutAccountNumber.allSatisfy({ $0.isNumber })
    }
}

#Preview {
    NavigationView {
        PayoutSetupView()
            .environmentObject(StoreRegistrationViewModel())
    }
}

// ✅ MATCHING FIELD STYLE
private extension View {
    func fieldStyle() -> some View {
        self
            .padding(12)
            .background(Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
