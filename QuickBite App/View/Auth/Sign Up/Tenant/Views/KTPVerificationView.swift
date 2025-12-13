//
//  KTPVerificationView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct KTPVerificationView: View {
    @EnvironmentObject var storeVM: StoreRegistrationViewModel
    
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    @State private var isKtpUploaded = false

    // ✅ PhotosUI States
    @State private var showGallery = false
    @State private var showCamera = false
    @State private var showPhotoOptions = false
    @State private var pickedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {

            RegistrationHeader(step: 2,
                               title: "KTP Verification",
                               subtitle: "Please upload a clear image of your KTP (Kartu Tanda Penduduk) for identity verification")

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification Note")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("The name on the KTP must match the Account Holder Name that you are going to provide in the next step.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    ZStack {
                        if let img = storeVM.ktpImage, isKtpUploaded {
                            VStack(spacing: 12) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(8)

                                Text("Uploaded Successfully!")
                                    .font(.headline)
                                    .foregroundColor(.orange)

                                Button("Click again to replace image") {
                                    showPhotoOptions = true
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                        } else {
                            Button(action: {
                                showPhotoOptions = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.up.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.secondary)

                                    Text("Click here to upload KTP photo")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)

                                    Text("PNG, JPG, or JPEG only (max. 5 MB)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundColor(.secondary)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .scrollIndicators(.hidden)

            NavigationLink(destination: PayoutSetupView(),
                           label: {
                OrangeButton(title: "Continue", enabled: isKtpUploaded)
            })
            .simultaneousGesture(TapGesture().onEnded {
                Task {
                    do {
                        try await authVM.updateOnboardingStep(3)
                    } catch {
                        print("Failed to update onboarding step: \(error.localizedDescription)")
                    }
                }
            })
            .padding()
        }

        // ✅ PHOTO OPTIONS SHEET (same pattern as EditProfileTenantView)
        .sheet(isPresented: $showPhotoOptions) {
            VStack(spacing: 0) {
                Text("Upload KTP Photo")
                    .font(.headline)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                Divider()

                Button {
                    showPhotoOptions = false
                    showGallery = true
                } label: {
                    row(icon: "photo.on.rectangle.angled",
                        title: "Choose from Gallery")
                }

                Divider()

                Button {
                    showPhotoOptions = false
                    showCamera = true
                } label: {
                    row(icon: "camera.fill", title: "Take Photo")
                }

                Spacer(minLength: 0)
            }
            .padding()
            .presentationDetents([.height(180)])
            .presentationDragIndicator(.visible)
        }

        // ✅ GALLERY PICKER (PhotosUI)
        .photosPicker(isPresented: $showGallery, selection: $pickedItem)
        .onChange(of: pickedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    storeVM.ktpImage = uiImage
                    isKtpUploaded = true
                }
            }
        }

        // ✅ CAMERA PICKER (unchanged pattern)
        .sheet(isPresented: $showCamera) {
            CameraPickerViewModel(image: $storeVM.ktpImage)
                .onDisappear {
                    if storeVM.ktpImage != nil {
                        isKtpUploaded = true
                    }
                }
        }
    }

    // ✅ Reused helper style from EditProfileTenantView
    private func row(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.15))
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 32, height: 32)

            Text(title)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationView {
        KTPVerificationView()
            .environmentObject(StoreRegistrationViewModel())
    }
}
