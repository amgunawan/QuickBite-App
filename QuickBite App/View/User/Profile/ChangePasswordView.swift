//
//  ChangePasswordView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showCurrent = false
    @State private var showNew = false
    @State private var showConfirm = false
    
    @FocusState private var focused: Field?
    enum Field { case current, new, confirm }
    
    // ViewModel untuk validasi password
    @StateObject private var passwordChecker = PasswordCheckViewModel()
    
    // MARK: - Computed properties
    private var isMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }
    
    private var isDifferentFromCurrent: Bool {
        !newPassword.isEmpty && newPassword != currentPassword
    }
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        passwordChecker.isPasswordValid &&
        isMatch &&
        isDifferentFromCurrent
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Current Password
                VStack(alignment: .leading, spacing: 8) {
                    requiredLabel("Current Password")
                    PasswordFieldWithToggle(
                        placeholder: "Type your current password",
                        text: $currentPassword,
                        isSecure: !showCurrent,
                        onToggle: { showCurrent.toggle() }
                    )
                    .focused($focused, equals: .current)
                }
                
                // New Password
                VStack(alignment: .leading, spacing: 8) {
                    requiredLabel("New Password")
                    PasswordFieldWithToggle(
                        placeholder: "Type your new password",
                        text: $newPassword,
                        isSecure: !showNew,
                        onToggle: { showNew.toggle() }
                    )
                    .focused($focused, equals: .new)
                    .onChange(of: newPassword) {
                        passwordChecker.password = newPassword
                    }
                    
                    // Validasi visual dari PasswordCheckViewModel
                    Group {
                        if !passwordChecker.hasValidLength && !newPassword.isEmpty {
                            Text("Password must be 8–20 characters long.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        if !passwordChecker.hasLetterAndNumber && !newPassword.isEmpty {
                            Text("Password must contain both letters and numbers.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        if !passwordChecker.hasSpecialCharacter && !newPassword.isEmpty {
                            Text("Password must include at least one special character.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        if !isDifferentFromCurrent && !newPassword.isEmpty {
                            Text("New password must be different from current password.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Confirm Password
                VStack(alignment: .leading, spacing: 8) {
                    requiredLabel("Confirm New Password")
                    PasswordFieldWithToggle(
                        placeholder: "Confirm your new password",
                        text: $confirmPassword,
                        isSecure: !showConfirm,
                        onToggle: { showConfirm.toggle() }
                    )
                    .focused($focused, equals: .confirm)
                    
                    if !isMatch && !confirmPassword.isEmpty {
                        Text("Passwords do not match.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Submit Button
                Button(action: handleChangePassword) {
                    Text("Change password")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isFormValid ? Color.orange : Color(.systemGray4))
                        .cornerRadius(24)
                }
                .disabled(!isFormValid)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .navigationTitle("Change Password")
        }
    }
    
    private func handleChangePassword() {
        // TODO: sambungkan ke ViewModel / API
        dismiss()
    }
    
    private func requiredLabel(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
            Text("*")
                .foregroundColor(.orange)
                .font(.subheadline)
        }
    }
}

// MARK: - Custom Password Field
struct PasswordFieldWithToggle: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.gray)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button(action: onToggle) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4))
        )
    }
}
