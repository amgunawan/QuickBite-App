//
//  ChangePasswordView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var resetVM = PasswordResetViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Image(systemName: "lock.rotation")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                    .padding(.top, 20)

                Text("Change Password")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("We’ll send you a secure email link to reset your password. Please complete the process through the email.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let email = Auth.auth().currentUser?.email {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4))
                    )
                }

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

                Button {
                    guard let email = Auth.auth().currentUser?.email else {
                        resetVM.errorMessage = "Unable to retrieve email."
                        return
                    }
                    resetVM.sendResetEmail(email: email)
                } label: {
                    if resetVM.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Send Reset Email")
                            .fontWeight(.medium)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.orange)
                .cornerRadius(24)
                .disabled(resetVM.isLoading)

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Change Password")
        }
    }
}
