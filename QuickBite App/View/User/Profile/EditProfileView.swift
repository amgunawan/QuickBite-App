import SwiftUI
import PhotosUI
import UIKit

struct EditProfileView: View {
    let username: String
    @Binding var fullName: String
    @Binding var phoneCode: String
    @Binding var phone: String
    @Binding var email: String
    let points: Int
    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var pickedItem: PhotosPickerItem?
    @State private var profileImage: UIImage? = nil

    enum Field { case fullName, phone, email }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    ZStack {
                        if let image = profileImage {
                            Image(uiImage: image)
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

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.orange)
                        Text("\(points) Points")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 6)

                // MARK: - Form Section
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Username")
                        TextField("", text: .constant(username))
                            .disabled(true)
                            .textFieldStyle(.roundedBorder)
                            .opacity(0.7)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Full Name")
                        HStack {
                            TextField("Your full name", text: $fullName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .fullName)

                            if !fullName.isEmpty {
                                Button {
                                    fullName = ""
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

                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Phone Number")
                        HStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Text("🇮🇩")
                                Text(phoneCode)
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 44)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))

                            TextField("81230300020", text: $phone)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .phone)
                                .padding(10)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Email")
                        TextField("name@example.com", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button {
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
                
                Spacer()
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Overlay Sheet
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
                    row(icon: "photo.on.rectangle.angled", title: "Choose from Gallery")
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
            .padding(.horizontal, 18)
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(22)
        }

        // Gallery Picker
        .photosPicker(isPresented: $showGallery, selection: $pickedItem)
        .onChange(of: pickedItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = uiImage
                }
            }
        }

        // Camera Sheet
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $profileImage)
        }
    }

    // MARK: - Reusable Components
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

    private func labelRequired(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
            Text("*").foregroundColor(.orange)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}

// MARK: - Camera Picker
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
