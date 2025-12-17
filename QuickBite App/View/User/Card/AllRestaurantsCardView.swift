//
//  AllRestaurantsCardView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct AllRestaurantsCardView: View {
    var imageURL: String?
    var deliveryTime: String
    var name: String
    var rating: String
    var reviewCount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Load image from URL
            if let imageURL = imageURL,
               let url = URL(string: imageURL) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                        )
                }
                .aspectRatio(1, contentMode: .fill)
                .clipShape(
                    RoundedCorners(radius: 12, corners: [.topLeft, .topRight])
                )
                
            } else {
                // fallback
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(
                        RoundedCorners(radius: 12, corners: [.topLeft, .topRight])
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(deliveryTime)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("\(rating) • \(reviewCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct RoundedCorners: Shape {
    var radius: CGFloat = .infinity
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
