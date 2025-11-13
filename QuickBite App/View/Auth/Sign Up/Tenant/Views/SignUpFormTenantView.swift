//
//  SignUpFormTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 10/11/25.
//

import SwiftUI

struct SignUpFormTenantView: View {
    var body: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 16) {
                Text("Reach out more customers with QuickBite")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Maximize sales during UC’s rush hour!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 24) {
                FeatureRow(icon: "person.3.fill",
                           title: "Guaranteed Daily Traffic",
                           subtitle: "Tap directly into hungry and time-constrained UC students.")
                
                FeatureRow(icon: "creditcard.fill",
                           title: "Merchant Payout Protection",
                           subtitle: "QuickBite will charge Rp. 2,500-/order which will be charged directly to the customer, ensuring your full profit margin.")
                
                FeatureRow(icon: "clock.fill",
                           title: "Optimized Pre-Orders",
                           subtitle: "Receive orders hours in advance, streamlining your preparation during peak class breaks.")
            }
            .padding(.horizontal)
            
            Spacer()
            
            NavigationLink(destination: StoreLocationDetailsView()) {
                Text("Start Registration")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(100)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}


#Preview {
    SignUpFormTenantView()
}
