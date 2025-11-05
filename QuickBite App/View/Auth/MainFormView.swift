//
//  SignInView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct MainFormView: View {
    @State private var selectedTab = 0
    @State private var email = ""
    @State private var password = ""
    @State private var showingGoogleSignInAlert = false
    @State private var showHome = false
    @State private var showPassword = false
    
    // MARK: - Validation
    private var isSignInDisabled: Bool {
        // Hilangkan spasi di awal/akhir sebelum cek kosong
        email.trimmingCharacters(in: .whitespaces).isEmpty ||
        password.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
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
                    Text("Sign in").tag(0)
                    Text("Sign up").tag(1)
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
                                TextField("e-mail address", text: $email)
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
                                    TextField("password", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("password", text: $password)
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
                            showHome = true
                        }) {
                            Text("Sign in")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSignInDisabled ? Color(.systemGray4) : Color.orange)
                                .cornerRadius(24)
                        }
                        .disabled(isSignInDisabled)
                        
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
                            showingGoogleSignInAlert = true
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
                        .alert("\"QuickBite\" Wants to Use \"google.com\" to Sign In", isPresented: $showingGoogleSignInAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Continue") {
                                // Aksi implementasi Google Sign-In
                            }
                        } message: {
                            Text("This allows the app to share information about you.")
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
            .fullScreenCover(isPresented: $showHome) {
                UserContentView()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    MainFormView()
}
