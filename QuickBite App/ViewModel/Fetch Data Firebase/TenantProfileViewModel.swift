//
//  TenantProfileViewModel.swift
//  QuickBite App
//
//  Created by Angela on 15/12/25.
//

import FirebaseFirestore
import FirebaseStorage
import Combine
import FirebaseAuth

@MainActor
class TenantProfileViewModel: ObservableObject {

    @Published var tenantUsername: String = ""
    @Published var tenantEmail: String = ""
    @Published var tenantFullName: String = ""
    @Published var tenantProfileImage: UIImage?

    private let storage = Storage.storage()
    private let db = Firestore.firestore()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // LOAD DATA
    func loadTenantFromEmail() {
        guard let email = Auth.auth().currentUser?.email else { return }
        tenantEmail = email

        db.collection("users")
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, _ in
                guard
                    let self,
                    let doc = snapshot?.documents.first
                else { return }

                let data = doc.data()
                self.tenantUsername = data["username"] as? String ?? ""
                self.tenantFullName = data["full_name"] as? String ?? ""
            }
    }

    // ✅ UPDATE FULL NAME
    func updateFullName(_ newName: String) async {
        guard let email = Auth.auth().currentUser?.email else { return }

        let snapshot = try? await db.collection("users")
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments()

        guard let doc = snapshot?.documents.first else { return }

        try? await doc.reference.updateData([
            "full_name": newName
        ])

        // update local state
        tenantFullName = newName
    }

    // MARK: - CHECK & LOAD AVATAR
    func loadProfileImage() async {
        guard let uid = userId else { return }
        
        let ref = storage.reference()
            .child("User")
            .child("\(uid).jpg")
        
        do {
            let data = try await ref.data(maxSize: 5 * 1024 * 1024)
            tenantProfileImage = UIImage(data: data)
        } catch {
            // ❌ File not found → default avatar
            tenantProfileImage = nil
        }
    }
    
    // MARK: - UPLOAD / REPLACE AVATAR
    func updateProfileImage(_ image: UIImage) async {
        guard let uid = userId,
              let data = image.jpegData(compressionQuality: 0.85)
        else { return }
        
        let ref = storage.reference()
            .child("User")
            .child("\(uid).jpg")
        
        do {
            _ = try await ref.putDataAsync(data)
            tenantProfileImage = image   // 🔁 sync langsung
        } catch {
            print("Upload avatar failed:", error)
        }
    }
    
    func deleteProfileImage() async {
        guard let uid = userId else { return }
        
        let ref = storage.reference()
            .child("User")
            .child("\(uid).jpg")
        
        do {
            try await ref.delete()
            tenantProfileImage = nil // sync ke semua view
        } catch {
            print("Failed to delete profile image:", error)
        }
    }
}
