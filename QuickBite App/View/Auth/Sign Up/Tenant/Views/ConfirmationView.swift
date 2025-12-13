//
//  ConfirmationView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI
import FirebaseAuth

struct ConfirmationView: View {
    @EnvironmentObject var storeVM: StoreRegistrationViewModel
    
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    let setupAction: () -> Void
    
    // ✅ Derived username from Firebase email
    private var userName: String {
        let email = Auth.auth().currentUser?.email ?? ""
        return email.components(separatedBy: "@").first ?? "User"
    }
    
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
                
                Text("Welcome, \(userName)!")
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                    .font(.title2)
                    .multilineTextAlignment(.center)

                Text("You can't sell until your menu is online. Lets create your digital store and menu book now!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
            
            NavigationLink(destination: StoreBrandingView()) {
                OrangeButton(title: "Start Menu Setup", enabled: true)
            }
            .simultaneousGesture(TapGesture().onEnded {
                Task {
                    do {
                        try await authVM.updateOnboardingStep(5)
                    } catch {
                        print("Failed to update onboarding step: \(error.localizedDescription)")
                    }
                }
            })
            .padding(.horizontal, 60)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationView {
        ConfirmationView(setupAction: {})
            .environmentObject(StoreRegistrationViewModel())
    }
}
