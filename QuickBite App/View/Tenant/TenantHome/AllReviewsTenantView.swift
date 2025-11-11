//
//  AllReviewsTenantView.swift
//  QuickBite
//
//  Created by Angela on 10/11/25.
//

import SwiftUI

struct TenantReview: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let rating: Int
    let text: String
    let menu: String
}

struct AllReviewsTenantView: View {
    // MARK: - States
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .newest
    @State private var selectedRatingFilter: Int? = nil

    @State private var reviews: [TenantReview] = [
        TenantReview(name: "Amanda Liu", date: Date(timeIntervalSince1970: 1730246400),
                     rating: 5, text: "Tasty and affordable. Pickup was smooth and easy.",
                     menu: "Katsutama Donburi"),
        TenantReview(name: "James Park", date: Date(timeIntervalSince1970: 1730246400),
                     rating: 4, text: "Really good! The katsu is crispy and the broth is flavorful.",
                     menu: "Chicken Katsu Shiokara Ramen"),
        TenantReview(name: "Sarah Luvita", date: Date(timeIntervalSince1970: 1730159999),
                     rating: 5, text: "Good food, quick service.",
                     menu: "Chicken Katsu Curry Rice"),
        TenantReview(name: "Michael Tan", date: Date(timeIntervalSince1970: 1730073600),
                     rating: 5, text: "The portion is generous and the sauce is perfect.",
                     menu: "Chicken Katsu Curry Rice"),
        TenantReview(name: "Jessica Lau", date: Date(timeIntervalSince1970: 1729987200),
                     rating: 5, text: "Best food at UC Walk! Always fresh and delicious.",
                     menu: "Katsutama Donburi")
    ]

    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case highest = "Highest Rating"
        case lowest = "Lowest Rating"
    }

    // MARK: - Computed Properties
    var filteredReviews: [TenantReview] {
        var filtered = reviews

        if let rating = selectedRatingFilter {
            filtered = filtered.filter { $0.rating == rating }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.menu.localizedCaseInsensitiveContains(searchText) ||
                $0.text.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .newest: filtered.sort { $0.date > $1.date }
        case .oldest: filtered.sort { $0.date < $1.date }
        case .highest: filtered.sort { $0.rating > $1.rating }
        case .lowest: filtered.sort { $0.rating < $1.rating }
        }

        return filtered
    }

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.map { Double($0.rating) }.reduce(0, +)
        return total / Double(reviews.count)
    }

    var ratingDistribution: [Int: Int] {
        Dictionary(grouping: reviews, by: { $0.rating }).mapValues { $0.count }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search by menu item or comment...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Sort Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sort by")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button(action: { sortOption = option }) {
                                        Text(option.rawValue)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(sortOption == option ? Color.orange : Color(.systemGray5))
                                            .foregroundColor(sortOption == option ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Filter by Rating
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Filter by rating")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button(action: { selectedRatingFilter = nil }) {
                                    Text("All (\(reviews.count))")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedRatingFilter == nil ? Color.orange : Color(.systemGray5))
                                        .foregroundColor(selectedRatingFilter == nil ? .white : .primary)
                                        .clipShape(Capsule())
                                }

                                ForEach((1...5).reversed(), id: \.self) { star in
                                    let count = ratingDistribution[star] ?? 0
                                    Button(action: { selectedRatingFilter = star }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                            Text("\(star) (\(count))")
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedRatingFilter == star ? Color.orange : Color(.systemGray5))
                                        .foregroundColor(selectedRatingFilter == star ? .white : .primary)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Rating Summary (Orange Card)
                    
                    let cardBg   = Color(red: 1.00, green: 0.96, blue: 0.89) // creamy soft orange
                    let barFill  = Color(red: 1.00, green: 0.65, blue: 0.20) // warm orange (match stars)
                    let starTint = barFill

                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 6) {
                            // Left: score + stars + total
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(format: "%.1f", averageRating))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.black)

                                RatingStars(rating: averageRating, size: 20)
                                    .foregroundColor(starTint)

                                Text("\(reviews.count) total reviews")
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.75))
                            }

                            Spacer(minLength: 16)

                            // Right: distribution 5…1 with star icon on label
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach((1...5).reversed(), id: \.self) { star in
                                    HStack(spacing: 8) {
                                        // "5 ★" label
                                        HStack(spacing: 4) {
                                            Text("\(star)")
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(starTint)
                                        }
                                        .frame(width: 28, alignment: .leading)

                                        // progress bar (white track + orange fill)
                                        GeometryReader { geo in
                                            let total = max(reviews.count, 1)
                                            let ratio = CGFloat(ratingDistribution[star] ?? 0) / CGFloat(total)
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(Color.white.opacity(1))
                                                    .frame(height: 8)
                                                Capsule()
                                                    .fill(barFill)
                                                    .frame(width: geo.size.width * ratio, height: 8)
                                            }
                                        }
                                        .frame(height: 8)

                                        // count at right
                                        Text("\(ratingDistribution[star] ?? 0)")
                                            .font(.subheadline)
                                            .foregroundColor(.black.opacity(0.8))
                                            .frame(width: 28, alignment: .trailing)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(16)
                    .background(cardBg)
                    .cornerRadius(18)
                    .padding(.horizontal)


                    // Review List / Empty State
                    if filteredReviews.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(Color(.systemGray3))
                            Text("No reviews found")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("Try adjusting your filters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredReviews) { review in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(review.name)
                                                .font(.headline)
                                            Text(dateFormatter.string(from: review.date))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        RatingStars(rating: Double(review.rating), size: 14)
                                    }
                                    Text(review.text)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(review.menu)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("All Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
        }
    }
}

// MARK: - Preview
#Preview {
    AllReviewsTenantView()
}
