//
//  OrangeButton.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct OrangeButton: View {
    let title: String
    let action: () -> Void
    var enabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(enabled ? Color.orange : Color.gray.opacity(0.3))
                .cornerRadius(100)
        }
        .disabled(!enabled)
    }
}
