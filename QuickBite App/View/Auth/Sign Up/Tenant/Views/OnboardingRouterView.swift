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
        NavigationStack {
            Group {
                if let session = authVM.currentUserSession {
                    switch session.role {
                    case .customer:
                        UserContentView()
                            .environmentObject(storeVM)
                            .environmentObject(navState)
                            .navigationBarBackButtonHidden(true)
                        
                    case .merchant:
                        switch session.onboardingStep {
                        case 0:
                            SignUpFormTenantView()
                        case 1:
                            StoreLocationDetailsView()
                        case 2:
                            KTPVerificationView()
                        case 3:
                            PayoutSetupView()
                        case 4:
                            ConfirmationView(setupAction: { })
                        case 5:
                            StoreBrandingView()
                        case 6:
                            MenuSetupView()
                        case 7:
                            OnboardingView()
                                .navigationBarBackButtonHidden(true)
                        case 8:
                            TenantContentView()
                                .navigationBarBackButtonHidden(true)
                        default:
                            SignUpFormTenantView()
                        }
                    }
                } else {
                    MainFormView()
                }
            }
        }
    }
}


#Preview {
    OnboardingRouterView()
}
