//
//  OnboardingView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var goToDashboard = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.orange)
                
                Text("Your Store is All Set Up!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: TenantContentView()) {
                    OrangeButton(title: "Go to Dashboard", enabled: true)
                }
                .padding(.horizontal)
                .padding(.vertical)
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
