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
                
                HStack (alignment: .top) {
                    Image(systemName: "checkmark.square")
                        .foregroundColor(.gray)
                    Text("By signing up, you agree to our ")
                    + Text("terms and conditions").foregroundColor(.blue)
                    + Text(" and ")
                    + Text("privacy policy").foregroundColor(.blue)
                }
                .font(.footnote)
                .foregroundColor(.gray)
                
                NavigationLink(destination: OTPCodeView(email: email)) {
                    Text("Continue")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(24)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}
