//
//  ConfirmationView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct ConfirmationView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            Text("Yout Store is All Set Up!")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            NavigationLink(destination: TenantProfileView()) {
                OrangeButton(title: "Go to Dashboard", action: {}, enabled: true)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}


#Preview {
    ConfirmationView()
}
