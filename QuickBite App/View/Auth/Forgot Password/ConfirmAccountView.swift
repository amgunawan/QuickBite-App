import SwiftUI
import FirebaseAuth

struct ConfirmAccountView: View {

    @EnvironmentObject var authVM: AuthenticationViewModel

    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm your email")
                    .font(.title)
                    .fontWeight(.bold)

                Text(
                    "We’ve sent a verification link to your email address. Please open the email and confirm your account."
                )
                .font(.headline)
                .foregroundStyle(.secondary)
            }

            // MARK: - Resend Verification
            Button {
                Task {
                    do {
                        try await authVM.resendEmailVerification()
                    } catch {
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            } label: {
                Text(
                    authVM.canResendVerification
                    ? "Resend verification email"
                    : "Resend in \(authVM.resendCooldownRemaining)s"
                )
                .foregroundColor(.orange)
            }
            .disabled(!authVM.canResendVerification)

            // MARK: - Refresh Verification Status
            Button {
                Task {
                    await reloadAndCheckVerification()
                }
            } label: {
                Text("I’ve verified my email")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(24)
            }

            // MARK: - Optional Sign Out
            Button("Sign out") {
                Task {
                    try? await authVM.signOut()
                }
            }
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            Task {
                await authVM.refreshEmailVerificationStatus()
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Reload Firebase User
    private func reloadAndCheckVerification() async {
        await authVM.refreshEmailVerificationStatus()

        if authVM.awaitingEmailVerification {
            alertMessage = "Email not verified yet."
            showAlert = true
        }
    }
}
