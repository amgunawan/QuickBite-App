import SwiftUI
import PhotosUI
import UIKit

struct EditProfileView: View {
    
    let username: String
    @Binding var fullName: String
    let email: String
    var userId: String
    var vm: ProfileViewModel
    var onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var pickedItem: PhotosPickerItem?
    @State private var profileImage: UIImage? = nil
    @State private var showDeleteAlert = false
    
    enum Field { case fullName, email }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Profile Avatar
                VStack(spacing: 8) {
                    ZStack {
                        if let image = profileImage ?? vm.profileImage {
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
                }
                .padding(.top, 6)
                
                // MARK: Form Fields
                VStack(spacing: 14) {
                    
                    // Username
                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Username")
                        TextField("", text: .constant(username))
                            .disabled(true)
                            .textFieldStyle(.roundedBorder)
                            .opacity(0.7)
                    }
                    
                    // Full Name
                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Full Name")
                        HStack {
                            TextField("Your full name", text: $fullName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .fullName)
                            if !fullName.isEmpty {
                                Button { fullName = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(10)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.5), lineWidth: focusedField == .fullName ? 1.2 : 0.3)
                        )
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        labelRequired("Email")
                        TextField("name@example.com", text: .constant(email))
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                            .disabled(true)
                            .foregroundColor(.secondary)
                    }
                    
                    // Save Button
                    Button {
                        if let image = profileImage {
                            vm.uploadProfileImage(image, userId: userId) { error in
                                if let error = error {
                                    print("Failed to upload image:", error.localizedDescription)
                                } else {
                                    print("Profile image uploaded successfully")
                                }
                            }
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
        .background(Color(.systemBackground))
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        
        // MARK: Load profile image from Firebase
        .onAppear { vm.loadProfileImage(userId: userId) }
        .onReceive(vm.$profileImage) { newImage in
            if profileImage == nil { profileImage = newImage }
        }
        
        // MARK: Photo Options Sheet
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
                } label: { row(icon: "photo.on.rectangle.angled", title: "Choose from Gallery") }
                
                Divider()
                
                Button {
                    showPhotoOptions = false
                    showCamera = true
                } label: { row(icon: "camera.fill", title: "Take Photo") }
                
                // Delete Button jika ada gambar
                if profileImage != nil || vm.profileImage != nil {
                    Divider()
                    Button { showDeleteAlert = true } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle().fill(Color.red.opacity(0.15))
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(width: 32, height: 32)
                            Text("Delete Profile Picture")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            .presentationDetents([.height(profileImage != nil || vm.profileImage != nil ? 240 : 180)])
            .presentationDragIndicator(.visible)
        }
        
        // MARK: Gallery Picker
        .photosPicker(isPresented: $showGallery, selection: $pickedItem)
        .onChange(of: pickedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = uiImage
                }
            }
        }
        
        // MARK: Camera Picker
        .sheet(isPresented: $showCamera) {
            CameraPickerViewModel(image: $profileImage)
        }
        
        // MARK: Delete Alert
        .alert("Delete Profile Picture?", isPresented: $showDeleteAlert, actions: {
            Button("Delete", role: .destructive) {
                vm.deleteProfileImage(userId: userId) { error in
                    if let error = error {
                        print("Failed to delete image:", error.localizedDescription)
                    } else {
                        profileImage = nil
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        })
    }
    
    // MARK: Label with Required Star
    private func labelRequired(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
            Text("*").foregroundColor(.orange)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    
    // MARK: Row Component
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
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileView()
}
