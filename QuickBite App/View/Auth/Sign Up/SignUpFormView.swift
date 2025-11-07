//
//  SignUpFormView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpFormView: View {
    let role: String
    @StateObject private var viewModel = EmailCheckViewModel()
    @StateObject private var passwordVM = PasswordCheckViewModel()
    @State private var agreeTermsAndConditions = false
    @State private var showPassword = false
    
    // Google Sign In
    @State private var loginError = ""
    @State private var isLoggedIn = false
    @State private var vm = AuthenticationViewModel()
    
    // Email Verification
    @State private var userVerificationModal: Bool = false
    
    private var canContinue: Bool {
        viewModel.isEmailValid && agreeTermsAndConditions && passwordVM.isPasswordValid
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Sign up as \(role)")
                    .font(.title)
                    .fontWeight(.bold)
                
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
                
                // Password field
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
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                
                // Password rules
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
                
                Button(action: {
                    Task {
                        userVerificationModal = true
                    }
                }) {
                    Text("Continue")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canContinue ? Color.orange : Color(.systemGray4))
                        .cornerRadius(24)
                }
                .disabled(!canContinue)
                .alert("Email Verification", isPresented: $userVerificationModal) {
                    Button("Verified?") {
                        
                    }
                } message: {
                    Text("We have sent a verification email to your address. Please check your inbox.")
                }
                
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                    Text("or")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                }
                
                Button(action: {
                    vm.signInWithGoogle()
                }) {
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
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(.systemGray4))
                    )
                }
                
                if !loginError.isEmpty {
                    Text(loginError)
                        .foregroundColor(.red)
                        .padding()
                }
                
                NavigationLink(value: isLoggedIn) {
                    EmptyView()
                }
                .navigationDestination(isPresented: $isLoggedIn) {
                    UserContentView()
                        .navigationBarBackButtonHidden(true)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

