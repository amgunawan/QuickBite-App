//
//  FindAccountView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct FindAccountView: View {
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment:. leading, spacing: 24) {
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
                        TextField("e-mail address", text: $email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
                }
                
                NavigationLink(destination: ConfirmAccountView()) {
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

#Preview {
    FindAccountView()
}
