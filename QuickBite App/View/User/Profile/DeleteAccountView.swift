//
//  DeleteAccountView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

struct DeleteAccountView: View {
    @State private var agreeDelete = false
    private let brandOrange = Color(red: 1.0, green: 0.584, blue: 0.0)
    @State private var showDeleteAccountAlert = false
    @State private var err: String = ""
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading, spacing: 24) {
                Text("After deletion, you will permanently lose access to the following information:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack (alignment: .leading, spacing: 8) {
                    Text("1. Order History")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Details of past transactions, saved addresses, payment methods, etc.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack (alignment: .leading, spacing: 8) {
                    Text("2. Promos & Rewards")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("All promos, vouchers, and loyalty points/rewards you’ve received.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack (alignment: .leading, spacing: 8) {
                    Text("3. Profile Data")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Personal information in your QuickBite profile.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray5))
                }
                
                Text("QuickBite is not responsible for any loss of information, data, or funds once your account is permanently deleted.")
                    .font(.subheadline)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        agreeDelete.toggle()
                    }
                } label: {
                    HStack (alignment: .top, spacing: 12) {
                        Image(systemName: agreeDelete ? "checkmark.square.fill" : "square")
                            .foregroundColor(agreeDelete ? Color.orange : Color(uiColor: .tertiaryLabel))
                            .imageScale(.large)
                        
                        Text("I agree and confirm to permanently delete my account.")
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                
                VStack(spacing: 12) {
                    Button(action: {
                        showDeleteAccountAlert = true
                    }) {
                        Text("Continue")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(agreeDelete ? Color.red : Color(.systemGray4))
                            .cornerRadius(24)
                    }
                    .disabled(!agreeDelete)
                    .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            Task {
                                do {
                                    try await AuthenticationViewModel().delete()
                                }
                                catch let e {
                                    err = e.localizedDescription
                                }
                            }
                        }
                    } message: {
                        Text("This action cannot be undone. This will permanently delete your account and remove all your data from our servers. Are you absolutely sure?")
                    }
                    .tint(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            
        }
        .navigationTitle("Delete Account")
    }
}

#Preview {
    DeleteAccountView()
}
