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
    
    // Start as NOT logged in. Do NOT check Auth here.
    @State private var userLoggedIn: Bool = false
    @State private var listenerAttached = false
    
    @StateObject private var authVM = AuthenticationViewModel()

    var body: some View {
        ZStack {
            VStack {
                if userLoggedIn {
                    UserContentView()
                } else {
                    MainFormView()
                }
            }
            .onAppear {
                attachAuthListenerIfNeeded()
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

    private func attachAuthListenerIfNeeded() {
        guard !listenerAttached else { return }
        listenerAttached = true

        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else {
                userLoggedIn = false
                return
            }

            // Only allow login when verified
            if user.isEmailVerified {
                userLoggedIn = true
            } else {
                // Prevent auto-login after signup
                userLoggedIn = false
            }
        }
    }
}

#Preview {
    InitialView()
}
