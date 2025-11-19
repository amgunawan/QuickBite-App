//
//  RegistrationHeader.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct MenuHeader: View {
    @Environment(\.dismiss) var dismiss
    
    let step: Int
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.orange)
                }
                
                Text("\(step). \(title)")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Spacer()
                Text("Step \(step) of 2")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.orange)
                        .frame(width: progressWidth(totalWidth: geometry.size.width), height: 8)
                        .animation(.easeOut, value: step)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
    }
    
    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        let maxSteps = 2
        let percentage = CGFloat(step) / CGFloat(maxSteps)
        return totalWidth * percentage
    }
}

#Preview {
    VStack(spacing: 40) {
        MenuHeader(step: 1, title: "Step 1", subtitle: "Start here.")
        MenuHeader(step: 2, title: "Step 2", subtitle: "Almost there.")
    }
}
