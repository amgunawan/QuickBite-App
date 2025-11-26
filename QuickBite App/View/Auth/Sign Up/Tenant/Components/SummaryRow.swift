//
//  SummaryRow.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI

struct SummaryRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary
    var weight: Font.Weight = .medium
    
    var body: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Text(value)
                .fontWeight(weight)
                .foregroundColor(valueColor)
        }
        .font(.system(size: 14))
    }
}
