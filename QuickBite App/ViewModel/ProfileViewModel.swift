//
//  ProfileViewModel.swift
//  QuickBite App
//
//  Created by Angela on 17/12/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage
import UIKit

class ProfileViewModel: ObservableObject {
    // MARK: - Published
    @Published var user: UserModel?
    @Published var profileImage: UIImage? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - Public API
    func loadUser(userId: String) {
        isLoading = true
        errorMessage = nil

        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                guard let self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard let snapshot, snapshot.exists else {
                        self.errorMessage = "User not found"
                        return
                    }

                    do {
                        self.user = try snapshot.data(as: UserModel.self)
                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
    
    func loadProfileImage(userId: String) {
        let ref = storage.reference(withPath: "User/\(userId)")
        ref.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.profileImage = image
                } else {
                    self?.profileImage = nil
                    print("No profile image found or error:", error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func deleteProfileImage(userId: String, completion: @escaping (Error?) -> Void) {
        let ref = storage.reference().child("User/\(userId)") // sama dengan upload
        ref.delete { error in
            completion(error)
        }
    }
}

extension ProfileViewModel {
    func updateFullName(to fullName: String, completion: ((Error?) -> Void)? = nil) {
        guard let userId = user?.id else {
            completion?(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"]))
            return
        }

        db.collection("users").document(userId).updateData([
            "full_name": fullName
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    completion?(error)
                } else {
                    // Update local model so UI stays in sync
                    self?.user?.full_name = fullName
                    completion?(nil)
                }
            }
        }
    }
}

extension ProfileViewModel {
    // MARK: - Upload / Replace profile image
    func uploadProfileImage(_ image: UIImage, userId: String, completion: ((Error?) -> Void)? = nil) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let ref = storage.reference(withPath: "User/\(userId)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        ref.putData(imageData, metadata: metadata) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion?(error)
                } else {
                    self?.profileImage = image
                    completion?(nil)
                }
            }
        }
    }
}
