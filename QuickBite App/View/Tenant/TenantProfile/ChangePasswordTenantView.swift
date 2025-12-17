//
//  ChangePasswordTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 05/11/25.
//

import SwiftUI
import FirebaseAuth

struct ChangePasswordTenantView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var resetVM = PasswordResetViewModel()

    private var userEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // MARK: Email Section (same structure as password sections)
                VStack(alignment: .leading, spacing: 8) {
                    requiredLabel("Email")

                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)

                        Text(userEmail.isEmpty ? "No email found" : userEmail)
                            .foregroundColor(userEmail.isEmpty ? .gray : .primary)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4))
                    )

                    Text("A secure password reset link will be sent to this email.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // MARK: Submit Button (IDENTICAL styling)
                Button {
                    resetVM.sendResetEmail(email: userEmail)
                } label: {
                    Text(resetVM.isLoading ? "Sending..." : "Send reset link")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            (!userEmail.isEmpty && !resetVM.isLoading)
                            ? Color.orange
                            : Color(.systemGray4)
                        )
                        .cornerRadius(24)
                }
                .disabled(userEmail.isEmpty || resetVM.isLoading)
                .padding(.top, 8)

                // MARK: Feedback (same placement as validation errors)
                if let error = resetVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                if let success = resetVM.successMessage {
                    Text(success)
                        .font(.caption)
                        .foregroundColor(.green)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .navigationTitle("Change Password")
            .toolbar(.hidden, for: .tabBar)
            .onChange(of: resetVM.successMessage) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        }
    }

    // MARK: Shared Label Helper (same as ChangePasswordView)
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
