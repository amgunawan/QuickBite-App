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
    
    
    private var isLengthOK: Bool { newPassword.count >= 8 }
    private var isMatch: Bool { !newPassword.isEmpty && newPassword == confirmPassword }
    private var isDifferentFromCurrent: Bool { !newPassword.isEmpty && newPassword != currentPassword }
    private var isFormValid: Bool {
        !currentPassword.isEmpty && isLengthOK && isMatch && isDifferentFromCurrent
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Current Password
                VStack(alignment: .leading, spacing: 6) {
                    requiredLabel("Current Password")
                    PasswordFieldWithToggle(
                        placeholder: "Type your current password",
                        text: $currentPassword,
                        isSecure: !showCurrent,
                        onToggle: { showCurrent.toggle() }
                    )
                    .focused($focused, equals: .current)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focused == .current ? Color.orange : Color.clear, lineWidth: 1)
                    )
                }
                
                // New Password
                VStack(alignment: .leading, spacing: 6) {
                    requiredLabel("New Password")
                    PasswordFieldWithToggle(
                        placeholder: "Type your new password",
                        text: $newPassword,
                        isSecure: !showNew,
                        onToggle: { showNew.toggle() }
                    )
                    .focused($focused, equals: .new)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focused == .new ? Color.orange : Color.clear, lineWidth: 1)
                    )
                    
                    if !isLengthOK && !newPassword.isEmpty {
                        Text("Minimum 8 characters.")
                            .font(.caption).foregroundColor(.red)
                    }
                    if !isDifferentFromCurrent && !newPassword.isEmpty {
                        Text("New password must be different from current.")
                            .font(.caption).foregroundColor(.red)
                    }
                }
                
                // Confirm New Password
                VStack(alignment: .leading, spacing: 6) {
                    requiredLabel("Confirm New Password")
                    PasswordFieldWithToggle(
                        placeholder: "Confirm your new password",
                        text: $confirmPassword,
                        isSecure: !showConfirm,
                        onToggle: { showConfirm.toggle() }
                    )
                    .focused($focused, equals: .confirm)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(focused == .confirm ? Color.orange : Color.clear, lineWidth: 1)
                    )
                    
                    if !isMatch && !confirmPassword.isEmpty {
                        Text("Passwords do not match.")
                            .font(.caption).foregroundColor(.red)
                    }
                }
                
                Button(action: handleChangePassword) {
                    Text("Change password")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isMatch ? Color.orange : Color(.systemGray4))
                        .cornerRadius(24)
                }
                .disabled(!isMatch)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Change Password")
    }
    
    private func handleChangePassword() {
        // TODO: sambungkan ke ViewModel / API
        dismiss()
    }
    
    private func requiredLabel(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
            Text("*").foregroundColor(.orange)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}

struct PasswordFieldWithToggle: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            
            Button(action: onToggle) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}
