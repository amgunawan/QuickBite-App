//
//  PayoutSetupView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct PayoutSetupView: View {
    @State private var bankName = ""
    @State private var accountHolderName = ""
    @State private var accountNumber = ""
    @State private var nmid = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            RegistrationHeader(step: 4,
                               title: "Payout & QRIS Setup",
                               subtitle: "Please provide your bank details for daily payouts and your QRIS identifier")
            
            Form {
                Section(header: Text("Bank Account Details")) {
                    
                    TextField("Bank Name (e.g., Bank Central Asia)", text: $bankName)
                        .autocapitalization(.words)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Enter full name on the account", text: $accountHolderName)
                            .autocapitalization(.words)
                        
                        Text("Account holder name must match the name on KTP uploaded")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Account Number (number only)", text: $accountNumber)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("QRIS")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("e.g., ID0000000000000", text: $nmid)
                            .autocapitalization(.allCharacters)
                        
                        Text("This is required for integrated digital payments. It should be provided by your QRIS provider.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            Button(action: {
                print("Final Registration Data Submitted!")
            }) {
                OrangeButton(title: "Complete Registration", action: {}, enabled: canComplete)
            }
            .padding()
            .simultaneousGesture(TapGesture().onEnded {
                hideKeyboard()
            })
        }
    }
    
    private var canComplete: Bool {
        !bankName.isEmpty &&
        !accountHolderName.isEmpty &&
        !accountNumber.isEmpty &&
        !nmid.isEmpty &&
        accountNumber.allSatisfy({ $0.isNumber })
    }
}

#Preview {
    NavigationView {
        PayoutSetupView()
    }
}
