//
//  FindAccountView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct CreateNewPasswordView: View {
    @StateObject private var viewModel = PasswordCheckViewModel()
    @State private var showHome = false
    @State private var showPassword = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Create a new password")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Password field
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if showPassword {
                        TextField("password", text: $viewModel.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("password", text: $viewModel.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                
                // Validation indicators
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your password must contain at least:")
                        .font(.subheadline)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(viewModel.hasValidLength ? .green : .secondary)
                        Text("8 characters (max. 20)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(viewModel.hasLetterAndNumber ? .green : .secondary)
                        Text("1 letter and 1 number")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(viewModel.hasSpecialCharacter ? .green : .secondary)
                        Text("1 special character (e.g., # ? ! $ & @)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Continue button
                Button(action: {
                    showHome = true
                }) {
                    Text("Continue")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.isPasswordValid ? Color.orange : Color(.systemGray4))
                        .cornerRadius(24)
                }
                .disabled(!viewModel.isPasswordValid)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .fullScreenCover(isPresented: $showHome) {
                UserContentView()
            }
        }
    }
}

#Preview {
    CreateNewPasswordView()
}
