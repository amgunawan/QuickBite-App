//
//  OnboardingView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI

struct OnboardingView: View {

    var body: some View {
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
                        
                        // BUTTON
                        OrangeButton(
                            title: "Go to Dashboard",
                            enabled: true
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    .navigationDestination(isPresented: $goToDashboard) {
                        TenantContentView()
                    }
                }
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

                NavigationLink(destination: TenantContentView()) {
                    OrangeButton(
                        title: "Go to Dashboard",
                        enabled: true
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    OnboardingView()
}

