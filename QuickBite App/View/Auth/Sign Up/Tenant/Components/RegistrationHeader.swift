//
//  RegistrationHeader.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct RegistrationHeader: View {
    let step: Int
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(step) of 4")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}
