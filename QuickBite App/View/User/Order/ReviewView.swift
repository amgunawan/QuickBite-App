//
//  ReviewView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI

struct ReviewView: View {
    // MARK: - Bindings from OrderCompletedView
    @Binding var rating: Int
    @Binding var didSubmit: Bool

    // MARK: - Local States
    @State private var reviewText: String = ""
    @State private var selectedImage: UIImage? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // MARK: - Restaurant Card
                    HStack(spacing: 12) {
                        Image("Raburi")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Raburi")
                                .font(.headline)
                            Text("Noodles, Japanese")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // MARK: - Rate the Restaurant
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rate the Restaurant")
                            .font(.subheadline)

                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(i <= rating ? .yellow : Color(.systemGray4))
                                    .onTapGesture {
                                        rating = i
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Photo Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add Photo(s)")
                            .font(.subheadline)

                        Button {
                            // Photo logic nanti
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "camera")
                                    .font(.title3)
                                Text("Photo")
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            )
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Write Review
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Write your Review")
                            .font(.subheadline)

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $reviewText)
                                .frame(minHeight: 120)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 50)
                }
                .padding(.top, 8)
            }

            // MARK: - Send Button
            Button(action: {
                didSubmit = true
                dismiss()
            }) {
                Text("Send")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FF9500"))
                    .cornerRadius(30)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Review the Restaurant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


//#Preview {
//    ReviewView()
//}
