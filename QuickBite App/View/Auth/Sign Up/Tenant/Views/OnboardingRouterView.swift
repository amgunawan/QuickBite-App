//
//  OnboardingRouterView.swift
//  QuickBite
//
//  Created by student on 12/12/25.
//

import SwiftUI

struct OnboardingRouterView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @EnvironmentObject var storeVM: StoreRegistrationViewModel
    @EnvironmentObject var navState: AppNavigationState
    
    var body: some View {
            // We use a Group so we can conditionally remove NavigationStack for the final dashboard
            Group {
                if let session = authVM.currentUserSession {
                    switch session.role {
                    case .customer:
                        UserContentView()
                            .environmentObject(storeVM)
                            .navigationBarBackButtonHidden(true)
                        
                    case .merchant:
                        // If finished (Step 8), show Dashboard directly (No NavigationStack needed)
                        if session.onboardingStep == 8 {
                            TenantContentView()
                                .environmentObject(storeVM)
                                .environmentObject(navState)
                                .transition(.opacity) // Smooth fade in
                        } else {
                            // Still onboarding? Use the Stack.
                            NavigationStack {
                                merchantView(for: session.onboardingStep)
                            }
                            // ⚡️ CRITICAL FIX: This forces the Stack to destroy/recreate
                            // whenever the step changes. This clears the "Zombie" history.
                            .id(session.onboardingStep)
                        }
                    }
                } else {
                    MainFormView()
                }
            }
            .animation(.default, value: authVM.currentUserSession?.onboardingStep)
        }
        
        @ViewBuilder
        func merchantView(for step: Int) -> some View {
            switch step {
            case 0: SignUpFormTenantView()
            case 1: StoreLocationDetailsView()
            case 2: KTPVerificationView()
            case 3: PayoutSetupView()
            case 4: ConfirmationView(setupAction: { })
            case 5: StoreBrandingView()
            case 6: MenuSetupView()
            case 7: OnboardingView().navigationBarBackButtonHidden(true)
            default: SignUpFormTenantView()
            }
        }
    }
    
    #Preview {
        OnboardingRouterView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(StoreRegistrationViewModel())
            .environmentObject(AppNavigationState())
    }
