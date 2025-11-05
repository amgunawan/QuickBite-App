//
//  FindAccountView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct FindAccountView: View {
    @StateObject private var viewModel = EmailCheckViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Find your account")
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
                
                NavigationLink(destination: ConfirmAccountView()) {
                    Text("Continue")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.isEmailValid ? Color.orange : Color(.systemGray4))
                        .cornerRadius(24)
                }
                .disabled(!viewModel.isEmailValid)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    FindAccountView()
}
