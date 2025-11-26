//
//  ReviewView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI
import PhotosUI

struct ReviewView: View {
    // MARK: - Bindings from OrderCompletedView
    @Binding var rating: Int
    @Binding var didSubmit: Bool
    var onSubmit: ((Int) -> Void)? = nil

    // MARK: - Local States
    @State private var reviewText: String = ""
    @State private var selectedImage: UIImage? = nil
    
    // MARK: - Photo Picker States
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var pickedItem: PhotosPickerItem?
    
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
                                    .onTapGesture { rating = i }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Photo Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add Photo(s)")
                            .font(.subheadline)

                        Button { showPhotoOptions = true } label: {
                            
                            VStack(spacing: 6) {
                                if let selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 90)
                                        .clipped()
                                        .cornerRadius(10)

                                } else {
                                    Image(systemName: "camera")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                    Text("Photo")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
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
                onSubmit?(rating)
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
        // MARK: - Photo Options Sheet
        .sheet(isPresented: $showPhotoOptions) {

            VStack(spacing: 0) {

                Text("Add Photo")
                    .font(.headline)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                Divider()

                Button {
                    showPhotoOptions = false
                    showGallery = true
                } label: {
                    sheetRow(icon: "photo.on.rectangle.angled",
                             title: "Choose from Gallery")
                }

                Divider()

                Button {
                    showPhotoOptions = false
                    showCamera = true
                } label: {
                    sheetRow(icon: "camera.fill",
                             title: "Take Photo")
                }

                Spacer(minLength: 0)

            }
            .padding(.horizontal, 18)
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(22)
        }


        // MARK: - Gallery Picker
        .photosPicker(isPresented: $showGallery, selection: $pickedItem)
        .onChange(of: pickedItem) {
            Task {
                if let newItem = pickedItem,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }

        // MARK: - CAMERA (your existing CameraPicker)
        .sheet(isPresented: $showCamera) {
            CameraPickerViewModel(image: $selectedImage)   // <-- use your own CameraPicker
        }
    }
    // MARK: - Bottom Sheet Row Component
    private func sheetRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 12)
    }
}


//#Preview {
//    ReviewView()
//}
