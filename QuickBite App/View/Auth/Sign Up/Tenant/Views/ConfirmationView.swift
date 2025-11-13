//
//  ConfirmationView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct ConfirmationView: View {
    let userName: String
    let setupAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            VStack(spacing: 20) {
                
                Image(systemName: "menucard.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.orange)
                    .padding(.bottom, 20)
                
                Text("Build your Digital Store")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                (
                    Text("Welcome, \(userName)!")
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                )
                .font(.title2)
                .multilineTextAlignment(.center)

                Text("You can't sell until your menu is online. Lets create your digital store and menu book now!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            .padding(.bottom, 40)
            
            NavigationLink(destination: StoreBrandingView(), label: {
                OrangeButton(title: "Start Menu Setup", action: {}, enabled: true)
            })
            .padding(.horizontal, 60)
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ConfirmationView(userName: "Sharon Tan", setupAction: {})
}
