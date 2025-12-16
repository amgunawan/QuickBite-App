//
//  ContentView.swift
//  QuickBite App
//
//  Created by Angela on 28/10/25.
//

import SwiftUI

struct UserContentView: View {

    // 🔑 GLOBAL STATES (SATU INSTANCE)
    @EnvironmentObject var navState: AppNavigationState
    @EnvironmentObject var cart: CartViewModel

    var body: some View {

        TabView(selection: $navState.selectedTab){

            // ================= HOME =================
            HomeView()
                .environmentObject(cart)
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // ================= ACTIVITY =================
            ActivityView()
                .environmentObject(navState)
                .environmentObject(cart)      
                .tag(1)
                .tabItem {
                    Label("Activity", systemImage: "clock.fill")
                }

            // ================= QUEST =================
            QuestView()
                .tag(2)
                .tabItem {
                    Label("Quest", systemImage: "trophy.fill")
                }

            // ================= PROFILE =================
            ProfileView()
                .tag(3)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    UserContentView()
        .environmentObject(AppNavigationState())
        .environmentObject(CartViewModel())
}
