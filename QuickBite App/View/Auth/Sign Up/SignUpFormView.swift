//
//  SignUpFormView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpFormView: View {
    let role: UserRole            // .customer or .merchant
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = EmailCheckViewModel()
    @StateObject private var passwordVM = PasswordCheckViewModel()
    @StateObject private var authVM = AuthenticationViewModel()
    
    @State private var agreeTermsAndConditions = false
    @State private var showPassword = false
    
    // Local loading & error states
    @State private var isSubmitting: Bool = false
    
    // Alerts
    @State private var userVerificationModal: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    private var canContinue: Bool {
        viewModel.isEmailValid &&
        agreeTermsAndConditions &&
        passwordVM.isPasswordValid &&
        !isSubmitting
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Sign up as \(role == .customer ? "user" : "merchant")")
                    .font(.title)
                    .fontWeight(.bold)
                
                // EMAIL
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        
                        TextField("e-mail address", text: $viewModel.email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4))
                    )
                }
                
                // PASSWORD
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if showPassword {
                        TextField("password", text: $passwordVM.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("password", text: $passwordVM.password)
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
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4))
                )
                
                // PASSWORD RULES
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your password must contain at least:")
                        .font(.subheadline)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(passwordVM.hasValidLength ? .green : .secondary)
                        Text("8 characters (max. 20)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(passwordVM.hasLetterAndNumber ? .green : .secondary)
                        Text("1 letter and 1 number")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(passwordVM.hasSpecialCharacter ? .green : .secondary)
                        Text("1 special character (e.g., # ? ! $ & @)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // TERMS & CONDITIONS
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        agreeTermsAndConditions.toggle()
                    }
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: agreeTermsAndConditions ? "checkmark.square.fill" : "square")
                            .foregroundColor(agreeTermsAndConditions ? Color.orange : Color(uiColor: .tertiaryLabel))
                            .imageScale(.large)
                        
                        Text("By signing up, you agree to our ")
                        + Text("terms and conditions").foregroundColor(.blue)
                        + Text(" and ")
                        + Text("privacy policy").foregroundColor(.blue)
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                }
                .buttonStyle(.plain)
                
                // CONTINUE BUTTON (EMAIL SIGNUP)
                Button(action: {
                    Task {
                        await handleEmailSignUp()
                    }
                }) {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    } else {
                        Text("Continue")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .background(canContinue ? Color.orange : Color(.systemGray4))
                .cornerRadius(24)
                .disabled(!canContinue)
                .alert("Email Verification", isPresented: $userVerificationModal) {
                    Button("Back to Login") {
                        dismiss()
                    }
                } message: {
                    Text("We have sent a verification email to your address. Please check your inbox and verify your account before logging in.")
                }
                .alert("Sign Up Failed", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                
                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                }
                
                // GOOGLE SIGN-IN
                Button(action: {
                    authVM.signInWithGoogle(role: role)
                }) {
                    HStack {
                        Image("GoogleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign up with Google")
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(.systemGray4))
                    )
                }
                .disabled(isSubmitting)
                
                // If you later add a Published error in authVM, you can show it here.
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Helpers
    private func handleEmailSignUp() async {
        isSubmitting = true
        errorMessage = ""
        
        do {
            // Email & password from the local validators
            authVM.email = viewModel.email
            authVM.password = passwordVM.password
            
            try await authVM.signUp(role: role)
            userVerificationModal = true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isSubmitting = false
    }
}
