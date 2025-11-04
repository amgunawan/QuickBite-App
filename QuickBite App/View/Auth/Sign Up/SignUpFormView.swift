//
//  SignUpFormView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

struct SignUpFormView: View {
    let role: String
    @State private var email = ""
    @State private var showingGoogleSignInAlert = false
    @State private var agreeTermsAndConditions = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment:. leading, spacing: 24) {
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
                        TextField("e-mail address", text: $email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        agreeTermsAndConditions.toggle()
                    }
                } label: {
                    HStack (alignment: .top, spacing: 12) {
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
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: OTPCodeView(email: email)) {
                    Text("Continue")
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
                    .background(RoundedRectangle(cornerRadius: 24).stroke(Color(.systemGray4)))
                }
                .alert("\"QuickBite\" Wants to Use \"google.com\" to Sign In", isPresented: $showingGoogleSignInAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Continue") {
                        // Aksi jika user pilih Continue, bisa implementasi Google Sign-In
                    }
                } message: {
                    Text("This allows the app to share information about you.")
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}
