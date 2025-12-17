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

    @EnvironmentObject private var authVM: AuthenticationViewModel
    @EnvironmentObject private var storeVM: StoreRegistrationViewModel

    @EnvironmentObject var navState: AppNavigationState

    var body: some View {
        ZStack {

            // ===== MAIN CONTENT =====
            Group {
                if authVM.awaitingEmailVerification {
                    ConfirmAccountView()
                        .environmentObject(authVM)

                } else if authVM.currentUserSession == nil {
                    MainFormView()
                        .environmentObject(authVM)
                        .environmentObject(storeVM)

                } else {
                    OnboardingRouterView()
                        .environmentObject(authVM)
                        .environmentObject(storeVM)
                }
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
        .environmentObject(AppNavigationState()) // ✅ PREVIEW FIX
}
