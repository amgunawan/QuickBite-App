//
//  EditStoreDetailsView.swift
//  QuickBite App
//
//  Created by jessica tedja on 05/11/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct EditStoreDetailsTenantView: View {
    // Props dari parent
    let tenantusername: String
    @Binding var tenantfullName: String
    @Binding var tenantphoneCode: String
    @Binding var tenantphone: String
    @Binding var tenantemail: String
    var onSave: () -> Void

    // State untuk overlay & picker
    @State private var showChoosePhoto = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var pickedItem: PhotosPickerItem?
    @State private var profileImage: UIImage? = nil

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    enum Field { case fullName, phone, email }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Edit Profile")
                    .font(.headline)
                Spacer()
                Button("Save") { onSave() }
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            ScrollView {
                VStack(spacing: 20) {

                    // === Avatar + Camera button ===
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
                                    .fill(
                                        LinearGradient(colors: [.orange, .orange.opacity(0.7)],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 96, height: 96)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 44))
                                            .foregroundColor(.white)
                                    )
                            }

                            // tombol kamera (pojok kanan bawah)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        showChoosePhoto = true
                                    } label: {
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.black.opacity(0.9))
                                            .padding(6)
                                            .background(.white, in: Circle())
                                            .shadow(radius: 1)
                                    }
                                    .offset(x: 6, y: 6)
                                }
                            }
                            .frame(width: 96, height: 96)
                        }
                    }
                    .padding(.top, 6)

                    // === FORM ===
                    VStack(spacing: 14) {
                        // Username (disabled)
                        VStack(alignment: .leading, spacing: 6) {
                            labelRequired("Username")
                            TextField("", text: .constant(tenantusername))
                                .disabled(true)
                                .textFieldStyle(.roundedBorder)
                                .opacity(0.7)
                        }

                        // Full Name + clear button
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
                                    .stroke(
                                        Color.orange.opacity(0.5),
                                        lineWidth: focusedField == .fullName ? 1.2 : 0.3
                                    )
                            )
                        }

                        // Phone
                        VStack(alignment: .leading, spacing: 6) {
                            labelRequired("Phone Number")
                            HStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Text("🇮🇩")
                                        .font(.body)
                                    Text(tenantphoneCode)
                                        .font(.body)
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 44)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))

                                TextField("82134584979", text: $tenantphone)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .phone)
                                    .font(.body)
                                    .padding(10)
                                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 6) {
                            labelRequired("Email")
                            TextField("name@example.com", text: $tenantemail)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .overlay(
            ChoosePhotoOverlay(
                isPresented: $showChoosePhoto,
                onPickGallery: {
                    showChoosePhoto = false
                    showPhotosPicker = true
                },
                onTakePhoto: {
                    showChoosePhoto = false
                    showCamera = true
                }
            )
        )

        .photosPicker(isPresented: $showPhotosPicker, selection: $pickedItem)
        .onChange(of: pickedItem) { oldValue, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiimg = UIImage(data: data) {
                    profileImage = uiimg
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $profileImage)
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
}

struct ChoosePhotoOverlay: View {
    @Binding var isPresented: Bool
    var onPickGallery: () -> Void
    var onTakePhoto: () -> Void

    @State private var yOffset: CGFloat = 200 // animasi naik dari bawah

    var body: some View {
        ZStack {
            if isPresented {
                // Latar belakang blur gelap
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { close() }

                VStack(spacing: 0) {
                    Spacer() // tetap biar muncul di bawah

                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)

                        Text("Edit Profile")
                            .font(.headline)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)

                        Divider()

                        Button(action: { onPickGallery(); close() }) {
                            row(icon: "photo.on.rectangle.angled", title: "Choose from Gallery")
                        }

                        Divider()

                        Button(action: { onTakePhoto(); close() }) {
                            row(icon: "camera.fill", title: "Take Photo")
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.bottom, safeAreaBottom()) // ✅ tambahkan ini agar nempel di bawah
                    .offset(y: yOffset)
                    .onAppear { open() }
                    .onChange(of: isPresented) { _, newVal in
                        newVal ? open() : close()
                    }
                }
                .ignoresSafeArea(edges: .bottom) // ✅ biar area bawah penuh
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: yOffset)
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

            Text(title).foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private func safeAreaBottom() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom }
            .first ?? 0
    }

    private func open() { yOffset = 0 }
    private func close() {
        yOffset = 200
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isPresented = false }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.cameraCaptureMode = .photo
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

