//
//  AccountCredentialsView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct AccountCredentialsView: View {
    @State private var ownerFullName = ""
    @State private var emailAddress = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    var body: some View {
        VStack(spacing: 20) {
            
            RegistrationHeader(step: 2,
                               title: "Account Credentials",
                               subtitle: "These information will be used to manage your orders on Quickbite Merchant Dashboard")

            Form {
                Section {
                    // Owner/Manager Full Name
                    TextField("Owner/manager full name", text: $ownerFullName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)

                    // Email Address
                    TextField("e.g., budi.kopi@emailaddress.com", text: $emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.primary)
                        
                    // Password Field with Toggle
                    HStack {
                        if showPassword {
                            TextField("Enter secure password", text: $password)
                        } else {
                            SecureField("Enter secure password", text: $password)
                        }
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }

                    // Confirm Password Field with Toggle
                    HStack {
                        if showConfirmPassword {
                            TextField("Confirm password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm password", text: $confirmPassword)
                        }
                        Button(action: {
                            showConfirmPassword.toggle()
                        }) {
                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Section 2: Terms and Conditions with Custom Checkbox
                Section {
                    Button(action: {
                        agreedToTerms.toggle()
                    }) {
                        HStack(alignment: .top) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(agreedToTerms ? .orange : .gray)
                                .padding(.top, 2)
                                            
                            (Text("By signing up, you agree to our ") +
                            Text("terms and conditions").foregroundColor(.orange) +
                            Text(" and ") +
                            Text("privacy policy").foregroundColor(.orange))
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .scrollIndicators(.hidden)

            NavigationLink(destination: KTPVerificationView(),
                           label: {
                OrangeButton(title: "Continue", action: {}, enabled: canContinue)
            })
            .simultaneousGesture(TapGesture().onEnded {
                hideKeyboard()
            })
            .padding()
        }
    }

    private var canContinue: Bool {
        !ownerFullName.isEmpty &&
        !emailAddress.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword &&
        agreedToTerms
    }
}

#Preview {
    NavigationView {
        AccountCredentialsView()
    }
}
