//
//  LanguagesSelection Tenant.swift
//  QuickBite App
//
//  Created by jessica tedja on 05/11/25.
//

import SwiftUI

struct LanguageSelectionTenantView: View {
    @Binding var selectedLanguage: String
    var body: some View {
        VStack {
            Text("Current Language: \(selectedLanguage)")
            Button("Switch to Bahasa Indonesia") {
                selectedLanguage = "Bahasa Indonesia"
            }
        }
        .padding()
        .navigationTitle("Languages")
    }
}
