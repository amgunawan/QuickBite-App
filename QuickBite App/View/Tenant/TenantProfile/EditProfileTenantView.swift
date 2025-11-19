//
//  EditProfileTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 10/11/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct EditProfileTenantView: View {

    let tenantusername: String
    @Binding var tenantfullName: String
    @Binding var tenantphoneCode: String
    @Binding var tenantphone: String
    @Binding var tenantemail: String

    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var profileImage: UIImage? = nil
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var pickedItem: PhotosPickerItem?

    enum Field { case fullName, phone, email }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: Avatar Section
                VStack(spacing: 8) {
                    ZStack {
                        if let img = profileImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(LinearGradient(colors: [.orange, .orange.opacity(0.7)],
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing))
                                .frame(width: 96, height: 96)
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }

                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    showPhotoOptions = true
                                } label: {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.black.opacity(0.9))
                                        .padding(6)
                                        .background(.white, in: Circle())
                                        .offset(x: 6, y: 6)
                                }
                            }
                        }
                        .frame(width: 96, height: 96)
                    }
                }
                .padding(.top, 6)

                VStack(spacing: 14) {

                    // USERNAME
                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Username")
                        TextField("", text: .constant(tenantusername))
                            .disabled(true)
                            .textFieldStyle(.roundedBorder)
                            .opacity(0.7)
                    }

                    // FULL NAME
                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Full Name")
                        HStack {
                            TextField("Your full name", text: $tenantfullName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .fullName)

                            if !tenantfullName.isEmpty {
                                Button {
                                    tenantfullName = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(10)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.5),
                                        lineWidth: focusedField == .fullName ? 1.2 : 0.3)
                        )
                    }

                    // PHONE (LOCKED)
                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Phone Number")
                        HStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Text("🇮🇩")
                                Text(tenantphoneCode)
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 44)
                            .background(Color(.secondarySystemBackground),
                                        in: RoundedRectangle(cornerRadius: 8))

                            TextField("", text: $tenantphone)
                                .padding(10)
                                .background(Color(.secondarySystemBackground),
                                            in: RoundedRectangle(cornerRadius: 8))
                                .disabled(true)
                                .foregroundColor(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Email")
                        TextField("", text: $tenantemail)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                            .disabled(true)
                            .foregroundColor(.secondary)
                    }

                    Button {
                        if let data = profileImage?.jpegData(compressionQuality: 0.9) {
                            UserDefaults.standard.set(data, forKey: "tenant.avatar")
                        }
                        onSave()
                        dismiss()
                    } label: {
                        Text("Save")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(24)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            if let data = UserDefaults.standard.data(forKey: "tenant.avatar") {
                profileImage = UIImage(data: data)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)

        // PHOTO OPTIONS SHEET
        .sheet(isPresented: $showPhotoOptions) {
            VStack(spacing: 0) {
                Text("Edit Profile Photo")
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

        // GALLERY PICKER
        .photosPicker(isPresented: $showGallery, selection: $pickedItem)
        .onChange(of: pickedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = uiImage
                }
            }
        }

        // CAMERA PICKER
        .sheet(isPresented: $showCamera) {
            CameraPickerViewModel(image: $profileImage)
        }
    }

    private func labelRequired(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
            Text("*").foregroundColor(.orange)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

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
