//
//  MenuDetailsView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct MenuDetailsView: View {
    @State private var menuItems: [String] = [""]
    
    var body: some View {
        VStack(spacing: 20) {
            RegistrationHeader(step: 2,
                               title: "Menu Details",
                               subtitle: "List your top-selling items for QuickBite.")
            
            Form {
                ForEach(menuItems.indices, id: \.self) { index in
                    TextField("Menu Item \(index + 1)", text: $menuItems[index])
                }
                
                Button(action: {
                    menuItems.append("")
                }) {
                    Label("Add Another Item", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            NavigationLink(destination: OperatingHoursView()) {
                OrangeButton(title: "Continue", action: {}, enabled: !menuItems.allSatisfy { $0.isEmpty })
            }
            .padding()
        }
    }
}

#Preview {
    MenuDetailsView()
}
