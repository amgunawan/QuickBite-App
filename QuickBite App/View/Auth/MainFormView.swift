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
    
    // Email & password now live inside vm
    @StateObject private var vm = AuthenticationViewModel()
    
    @State private var showingLoginAlert = false
    @State private var alertMessage = ""
    @State private var showPassword = false
    
    @State private var isLoggedIn = false
    
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
                            Task {
                                await signInUser()
                            }
                        }) {
                            if vm.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            } else {
                                Text("Sign in")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                        .background(Color.orange)
                        .cornerRadius(24)
                        .disabled(vm.isLoading)
                        .alert(isPresented: $showingLoginAlert) {
                            Alert(title: Text("Sign In Failed"),
                                  message: Text(alertMessage),
                                  dismissButton: .default(Text("OK")))
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
                            vm.signInWithGoogle() // default role = .customer
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
                        .disabled(vm.isLoading)
                        
                        if let error = vm.errorMessage, !error.isEmpty {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                        
                        // Navigation after auth
                        NavigationLink(value: isLoggedIn) {
                            EmptyView()
                        }
                        .navigationDestination(isPresented: $isLoggedIn) {
                            // Route based on Firestore role
                            switch vm.currentUser?.role {
                            case .merchant:
                                // TODO: Replace with your merchant root view
                                TenantContentView()
                                    .navigationBarBackButtonHidden(true)
                            default:
                                UserContentView()
                                    .navigationBarBackButtonHidden(true)
                            }
                        }
                    }
                } else {
                    // MARK: - Sign Up selector
                    VStack(spacing: 16) {
                        NavigationLink(destination: SignUpFormView(role: .customer)) {
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
                        
                        NavigationLink(destination: SignUpFormView(role: .merchant)) {
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
            // When VM auth state changes, update local isLoggedIn
            .onChange(of: vm.isAuthenticated) { newValue in
                if newValue {
                    isLoggedIn = true
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func signInUser() async {
        do {
            try await vm.signInWithEmailPassword()
            // isLoggedIn will be set by onChange(of: vm.isAuthenticated)
        } catch {
            alertMessage = error.localizedDescription
            showingLoginAlert = true
        }
    }
}
