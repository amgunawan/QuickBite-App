//
//  TenantContentView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

struct TenantContentView: View {
    var body: some View {
        TabView {
            TenantHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TenantActivityView()
                .padding(.bottom)
                .tabItem {
                    Label("Activity", systemImage: "clock.fill")
                }
            
            TenantProfileView()
                .padding(.bottom)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    TenantContentView()
}
