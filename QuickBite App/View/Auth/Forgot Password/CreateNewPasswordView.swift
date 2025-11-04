//
//  FindAccountView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct CreateNewPasswordView: View {
    @State private var password = ""
    @State private var showHome = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment:. leading, spacing: 24) {
                Text("Create a new password")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    SecureField("password", text: $password)
                    Button(action: {}) {
                        Image(systemName: "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your password must contain at least:")
                        .font(.subheadline)
                    
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("8 characters (max. 20)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("1 letter and 1 number")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("1 special character (e.g., # ? ! $ & @)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button(action: {
                    showHome = true
                }) {
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
            .fullScreenCover(isPresented: $showHome) {
                UserContentView()
            }
        }
    }
}

#Preview {
    CreateNewPasswordView()
}
