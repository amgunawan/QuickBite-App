//
//  ContentView.swift
//  QuickBite App
//
//  Created by Angela on 28/10/25.
//

import SwiftUI

struct UserContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ActivityView()
                .padding(.bottom)
                .tabItem {
                    Label("Activity", systemImage: "clock.fill")
                }
            
            QuestView()
                .padding(.bottom)
                .tabItem {
                    Label("Quest", systemImage: "trophy.fill")
                }
            
            ProfileView()
                .padding(.bottom)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    UserContentView()
}
