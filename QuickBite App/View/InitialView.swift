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

    @StateObject private var authVM = AuthenticationViewModel()
    @StateObject private var storeVM = StoreRegistrationViewModel()

    @EnvironmentObject var navState: AppNavigationState

    @State private var showInvitationSheet = false
    @State private var incomingOrderId: String = ""
    
    @State private var userJoinedGroup = false
    @State private var navigateToRestaurant = false
    
    @EnvironmentObject var cart: CartViewModel
    
    var body: some View {
        ZStack {

            // ===== MAIN CONTENT =====
            Group {
                if authVM.currentUserSession == nil {

                    // 🔐 LOGIN / SIGNUP
                    MainFormView()
                        .environmentObject(authVM)
                        .environmentObject(storeVM)

                } else {

                    if authVM.currentUserSession == nil {
                        MainFormView()
                            .environmentObject(authVM)
                            .environmentObject(storeVM)
                    } else {
                        UserContentView()   // 🔥 INI DIGANTI
                            .environmentObject(authVM)
                            .environmentObject(storeVM)
                            .environmentObject(navState)
                    }

                }
            }

            // ===== SPLASH =====
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
        // 1. Listen for Notification Broadcast
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenGroupInvite"))) { notification in
            if let info = notification.userInfo, let id = info["orderId"] as? String {
                print("InitialView received order ID: \(id)")
                self.incomingOrderId = id
                
                if authVM.currentUserSession != nil {
                    self.showInvitationSheet = true
                }
            }
        }
        // 2. Show the Invitation Sheet
        .sheet(isPresented: $showInvitationSheet) {
            if !incomingOrderId.isEmpty {
                // FIX: Pass the binding ($userJoinedGroup) instead of 'false'
                InvitationView(
                    orderId: incomingOrderId,
                    isJoined: $userJoinedGroup
                )
            }
        }
        // 3. Watch for successful Join -> Trigger Navigation
        .onChange(of: userJoinedGroup) { joined in
            if joined {
                // Wait slightly for the sheet to dismiss, then navigate
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigateToRestaurant = true
                    userJoinedGroup = false // Reset for next time
                }
            }
        }
        // 4. Open the Restaurant Detail View
        .fullScreenCover(isPresented: $navigateToRestaurant) {
            NavigationStack {
                RestaurantDetailView(
                    restaurant: Restaurant(
                        id: incomingOrderId, // Use the ID passed in
                        name: "Loading...",   // Placeholder until you fetch real details
                        location: "",
                        rating: 0.0,
                        reviewCount: 0,
                        bannerURL: nil,
                        searchURL: nil,
                        cuisineType: [],
                        menuDataURL: nil // The ViewModel might need to handle fetching based on ID
                    )
                )
                // ⚠️ CRITICAL: Pass the cart environment object
                .environmentObject(cart)
                
                // Add a Close button since this is a modal
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            navigateToRestaurant = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InitialView()
        .environmentObject(AppNavigationState()) // ✅ PREVIEW FIX
}
