//
//  ReviewView.swift
//  QuickBite
//

import SwiftUI
import PhotosUI

struct ReviewView: View {

    // MARK: - Bindings
    @Binding var rating: Int
    @Binding var didSubmit: Bool
    var onSubmit: ((Int) -> Void)? = nil

    // MARK: - Local
    @State private var reviewText: String = ""
    @State private var selectedImages: [UIImage] = []

    // MARK: - Picker
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var pickedItem: PhotosPickerItem?

    @Environment(\.dismiss) private var dismiss

    // MARK: - Grid Layout (3 columns)
    private let grid = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // RESTO CARD
                    HStack(spacing: 12) {
                        Image("Raburi")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Raburi").font(.headline)
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

                    // STARS
                    VStack(alignment: .center, spacing: 8) {
                        Text("Rate the Restaurant")
                            .font(.subheadline)

                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { i in
                                Image(systemName: i <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(i <= rating ? .yellow : Color(.systemGray4))
                                    .onTapGesture { rating = i }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // ADD PHOTOS — GRID
                    VStack(alignment: .leading, spacing: 10) {

                        Text("Add Photo(s)")
                            .font(.subheadline)

                        if selectedImages.isEmpty {
                            // 👉 INITIAL — FULL WIDTH LANDSCAPE
                            Button { showPhotoOptions = true } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "camera")
                                        .font(.title3)
                                        .foregroundColor(.gray)

                                    Text("Add")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                            }
                        } else {
                            // 👉 AFTER FIRST UPLOAD — GRID SQUARES (3 columns)
                            LazyVGrid(columns: grid, spacing: 12) {

                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { idx, img in
                                    ZStack(alignment: .topTrailing) {

                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: squareWidth(), height: squareWidth())
                                            .clipped()
                                            .cornerRadius(12)

                                        Button {
                                            selectedImages.remove(at: idx)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.7))
                                                .clipShape(Circle())
                                                .padding(6)
                                        }
                                    }
                                }

                                // ADD PHOTO (square)
                                if selectedImages.count < 3 {
                                    Button { showPhotoOptions = true } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: "camera")
                                                .font(.title3)
                                                .foregroundColor(.gray)

                                            Text("Add")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: squareWidth(), height: squareWidth())
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        )
                                    }
                                }
                            }
                        }

                    }
                    .padding(.horizontal)

                    // REVIEW TEXT
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Write your Review")
                            .font(.subheadline)

                        TextEditor(text: $reviewText)
                            .frame(minHeight: 120)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4))
                            )
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 60)
                }
                .padding(.top, 10)
            }

            // SEND BUTTON
            Button {
                didSubmit = true
                onSubmit?(rating)
                dismiss()
            } label: {
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
            .navigationTitle("Review the Restaurant")
            .navigationBarTitleDisplayMode(.inline)
        }

        // PHOTO OPTIONS SHEET
        .sheet(isPresented: $showPhotoOptions) {
            VStack(spacing: 0) {

                Text("Add")
                    .font(.headline)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                Divider()

                Button {
                    showPhotoOptions = false
                    showGallery = true
                } label: {
                    sheetRow(icon: "photo.on.rectangle.angled", title: "Choose from Gallery")
                }

                Divider()

                Button {
                    showPhotoOptions = false
                    showCamera = true
                } label: {
                    sheetRow(icon: "camera.fill", title: "Take Photo")
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(22)
        }

        // GALLERY PICKER
        .photosPicker(isPresented: $showGallery, selection: $pickedItem)
        .onChange(of: pickedItem) {
            Task {
                guard selectedImages.count < 3 else { return }
                if let item = pickedItem,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    selectedImages.append(img)
                }
            }
        }

        // CAMERA
        .sheet(isPresented: $showCamera) {
            CameraPickerViewModel(image: Binding(
                get: { nil },
                set: { img in
                    if let photo = img, selectedImages.count < 3 {
                        selectedImages.append(photo)
                    }
                }
            ))
        }
    }

    // SQUARE SIZE CALCULATOR
    private func squareWidth() -> CGFloat {
        let screen = UIScreen.main.bounds.width
        let padding: CGFloat = 16 * 2
        let spacing: CGFloat = 12 * 2
        return (screen - padding - spacing) / 3
    }

    // SHEET ROW
    private func sheetRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.orange)
            Text(title).foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 12)
    }
}
