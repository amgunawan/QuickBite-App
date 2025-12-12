//
//  SignUpFormView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI
import FirebaseAuth

#if targetEnvironment(simulator)
let IS_SIMULATOR = true
#else
let IS_SIMULATOR = false
#endif

struct SignUpFormView: View {
    let role: UserRole

    // Validation helpers
    @StateObject private var emailValidator = EmailCheckViewModel()
    @StateObject private var passwordVM = PasswordCheckViewModel()

    // Injected AuthenticationViewModel
    @EnvironmentObject var authVM: AuthenticationViewModel

    @State private var agreeTermsAndConditions = false
    @State private var showPassword = false
    @State private var goNextScreen = false
    @State private var loginError = ""

    private var canContinue: Bool {
        emailValidator.isEmailValid && passwordVM.isPasswordValid && agreeTermsAndConditions
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {

                Text("Sign up as \(role.rawValue.capitalized)")
                    .font(.title)
                    .fontWeight(.bold)

                // MARK: - Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)

                        TextField("e-mail address", text: $authVM.email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                            .onChange(of: authVM.email) { newValue in
                                emailValidator.email = newValue
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                }

                // MARK: - Password Field
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)

                    if showPassword {
                        TextField("password", text: $authVM.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: authVM.password) { passwordVM.password = $0 }
                    } else {
                        SecureField("password", text: $authVM.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: authVM.password) { passwordVM.password = $0 }
                    }

                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))

                // MARK: - Password Rules
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your password must contain at least:")
                        .font(.subheadline)

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(passwordVM.hasValidLength ? .green : .secondary)
                        Text("8 characters (max. 20)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(passwordVM.hasLetterAndNumber ? .green : .secondary)
                        Text("1 letter and 1 number")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(passwordVM.hasSpecialCharacter ? .green : .secondary)
                        Text("1 special character (e.g., # ? ! $ & @)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // MARK: - Terms & Conditions
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        agreeTermsAndConditions.toggle()
                    }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: agreeTermsAndConditions ? "checkmark.square.fill" : "square")
                            .foregroundColor(agreeTermsAndConditions ? .orange : .gray)
                            .imageScale(.large)

                        (Text("By signing up, you agree to our ")
                            + Text("terms and conditions").foregroundColor(.blue)
                            + Text(" and ")
                            + Text("privacy policy").foregroundColor(.blue))
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)

                // MARK: - Continue Button
                Button {
                    Task { await performSignUp() }
                } label: {
                    Text("Continue")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canContinue ? Color.orange : Color(.systemGray4))
                        .cornerRadius(24)
                }
                .disabled(!canContinue)

                // MARK: - Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                    Text("or")
                        .foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                }

                // MARK: - Google Sign In
                Button {
                    authVM.signInWithGoogle(role: role)
                } label: {
                    HStack {
                        Image("GoogleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 24).stroke(Color(.systemGray4)))
                }

                if !loginError.isEmpty {
                    Text(loginError)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationDestination(isPresented: $goNextScreen) {
                switch role {
                case .customer:
                    UserContentView()
                        .navigationBarBackButtonHidden(true)
                case .merchant:
                    SignUpFormTenantView()
                        .navigationBarBackButtonHidden(true)
                }
            }
            .onAppear {
                emailValidator.email = authVM.email
                passwordVM.password = authVM.password
            }
        }
    }

    // MARK: - Sign Up Logic
    private func performSignUp() async {
        do {
            // Firebase signup + Firestore creation + loadCurrentUser
            try await authVM.signUp(role: role)

            // No email verification flow needed anymore
            goNextScreen = true

        } catch {
            loginError = error.localizedDescription
        }
    }
}
