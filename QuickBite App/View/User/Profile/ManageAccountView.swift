//
//  ManageAccountView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

struct ManageAccountView: View {
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.orange)
                            .font(.system(size: 22))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Logout")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("Sign out of your account.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .alert("Logout Confirmation", isPresented: $showLogoutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Logout", role: .destructive) {
                        // Aksi jika user pilih Logout
                    }
                } message: {
                    Text("Are you sure you want to logout? You will need to sign in again to access your account.")
                }
                .tint(.primary)
                
                NavigationLink(destination: DeleteAccountView()) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 22))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Delete Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your account will be deleted permanently, and")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("all your data will be lost.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Manage Account")
    }
}

#Preview {
    ManageAccountView()
}
