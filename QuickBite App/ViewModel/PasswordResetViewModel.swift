//
//  PasswordResetViewModel.swift
//  QuickBite App
//

import SwiftUI
import FirebaseAuth
import Combine

final class PasswordResetViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    func sendResetEmail(email: String) {
        guard !email.isEmpty else {
            errorMessage = "Email address not found."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                self?.successMessage = "Password reset link sent to your email."
            }
        }
    }
}
