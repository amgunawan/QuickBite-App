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

            // MARK: - Square Image (1:1, Grid Safe)
            GeometryReader { geo in
                ZStack {
                    if let imageURL = imageURL,
                       let url = URL(string: imageURL) {

                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()

                            case .failure(_):
                                Color.gray.opacity(0.15)

                            default:
                                Color.gray.opacity(0.15)
                                    .overlay(ProgressView())
                            }
                        }
                    } else {
                        Color.gray.opacity(0.15)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width)
                .clipped()
                .clipShape(
                    RoundedCorners(radius: 12, corners: [.topLeft, .topRight])
                )
            }
            .aspectRatio(1, contentMode: .fit)

            // MARK: - Text Section
            VStack(alignment: .leading, spacing: 4) {

                Text(deliveryTime)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

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
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - RoundedCorners Helper
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
