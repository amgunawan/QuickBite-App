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
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    
    @StateObject private var authVM = AuthenticationViewModel()
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                if userLoggedIn {
                    UserContentView()
                }
                else {
                    MainFormView()
                }
            }
            .onAppear {
                // Firebase state change listener
                Auth.auth().addStateDidChangeListener { auth, user in
                    if (user != nil) {
                        userLoggedIn = true
                    }
                    else {
                        userLoggedIn = false
                    }
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
}
