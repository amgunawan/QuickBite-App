//
//  SignInView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct MainFormView: View {
    @State private var selectedTab = 0
    @State private var email = ""
    @State private var password = ""
    @State private var showingGoogleSignInAlert = false
    @State private var showPassword = false
    
    // Google Sign In
    @State private var loginError = ""
    @State private var isLoggedIn = false
    @State private var vm = AuthenticationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer().frame(height: 2)
                
                VStack(spacing: 8) {
                    Text("Welcome to QuickBite")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Sign in or sign up to access your account.")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                }
                
                // MARK: - Segmented Control
                Picker("", selection: $selectedTab) {
                    Text("Sign In").tag(0)
                    Text("Sign Up").tag(1)
                }
                .pickerStyle(.segmented)
                
                // MARK: - Sign In Section
                if selectedTab == 0 {
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                TextField("e-mail address", text: $vm.email)
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
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                
                                if showPassword {
                                    TextField("password", text: $vm.password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("password", text: $vm.password)
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
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            NavigationLink(destination: FindAccountView()) {
                                Text("Forgot Password")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Sign In Button
                        Button(action: {
                            // sign in view model
                        }) {
                            Text("Sign in")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .cornerRadius(24)
                        }
                        
                        // Divider
                        HStack {
                            Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                            Text("or")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                        }
                                           
                        // Google Sign-In
                        Button(action: {
                            Task {
                                do {
                                    try await vm.signInWithGoogle()
                                    isLoggedIn = true
                                } catch {
                                    loginError = error.localizedDescription
                                }
                            }
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
                    }
                } else {
                    // MARK: - Sign Up Section
                    VStack(spacing: 16) {
                        NavigationLink(destination: SignUpFormView(role: "user")) {
                            Text("Sign up as user")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .cornerRadius(24)
                        }
                        
                        HStack {
                            Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                            Text("or")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                        }
                        
                        NavigationLink(destination: SignUpFormView(role: "merchant")) {
                            Text("Sign up as merchant")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .cornerRadius(24)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                loginError = error.localizedDescription
            }
            
            isLoggedIn = true
        }
    }
}

#Preview {
    MainFormView()
}
