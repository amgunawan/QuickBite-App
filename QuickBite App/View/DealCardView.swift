//
//  DealCardView.swift
//  QuickBite App
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct RoundedCorners: Shape {
    var radius: CGFloat = 10
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct DealCardView: View {
    var imageName: String
    var title: String
    var restaurant: String
    var priceNow: String
    var priceOld: String
    
    var cardWidth: CGFloat = 300
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            HStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(
                        RoundedCorners(radius: 12, corners: [.topLeft, .bottomLeft])
                    )
                    .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text(priceNow)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        
                        Text(priceOld)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }
            .frame(width: cardWidth, height: 90, alignment: .leading)
        }
        .fixedSize()
    }
}
