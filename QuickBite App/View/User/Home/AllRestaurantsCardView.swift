//
//  AllRestaurantsCardView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct AllRestaurantsCardView: View {
    var imageName: String
    var deliveryTime: String
    var name: String
    var rating: String = "4.7"
    var reviewCount: String = "50+ rating"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Gambar persegi dengan rasio 1:1 mengikuti lebar kartu
            Image(imageName)
                .resizable()
                .scaledToFill()
                .aspectRatio(1, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedCorners(radius: 12, corners: [.topLeft, .topRight])
                )
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deliveryTime)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
                
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
