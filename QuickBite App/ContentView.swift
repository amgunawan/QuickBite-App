//
//  ContentView.swift
//  QuickBite App
//
//  Created by Angela on 28/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "clock.fill")
                }
            
            QuestView()
                .tabItem {
                    Label("Quest", systemImage: "trophy.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
