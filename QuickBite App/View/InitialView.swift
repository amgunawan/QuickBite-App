//
//  InitialView.swift
//  QuickBite
//
//  Created by Angela on 07/11/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct InitialView: View {
    @State private var showSplash = true
    @State private var listenerAttached = false

    @EnvironmentObject private var authVM: AuthenticationViewModel
    @EnvironmentObject private var storeVM: StoreRegistrationViewModel // keep existing env usage

    var body: some View {
        ZStack {
            Group {
                // If no session -> show MainFormView (login / signup)
                if authVM.currentUserSession == nil {
                    MainFormView()
                        .environmentObject(authVM)
                        .environmentObject(storeVM)
                } else {
                    // We have a user session; route according to role + onboardingStep
                    OnboardingRouterView()
                        .environmentObject(authVM)
                        .environmentObject(storeVM)
                }
            }
            .onAppear {
                // nothing else — the authVM already attaches listener in init()
            }

            if showSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.6)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}


#Preview {
    InitialView()
        .environmentObject(StoreRegistrationViewModel())
}
