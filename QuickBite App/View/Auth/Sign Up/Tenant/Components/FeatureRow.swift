//
//  FeatureRow.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct FeatureRow: View {
    var icon: String
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(.orange)
                .frame(width: 40, height: 40)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}
