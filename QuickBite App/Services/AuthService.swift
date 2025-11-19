////
////  AuthService.swift
////  QuickBite
////
////  Created by Student on 19/11/25.
////
//
//import Foundation
//import Combine
//import FirebaseAuth
//import FirebaseFirestore
//
//enum AuthError: Error {
//    case firestoreWriteError(String)
//    case firestoreReadError(String)
//    case userDocumentNotFound
//    case authError(String)
//}
//
//class AuthService: ObservableObject {
//    @Published var currentUser: AppUser?
//    
//    // ... (register, signIn, signOut functions remain the same)
//    
//    // MARK: - Social Sign-In (Handling Google/Apple results)
//    
//    // This function is called AFTER Google Sign-In succeeds and gives you
//    // the Firebase Auth result wrapped in your AuthDataResultModel.
//    func handleSocialSignIn(result: AuthDataResultModel, role: UserRole) async throws {
//        
//        // Ensure we have an email, which is mandatory for your user schema
//        guard let email = result.email else {
//            // This case should be rare for Google, but essential to check
//            throw AuthError.authError("Social sign-in did not provide an email address.")
//        }
//        
//        let uid = result.uid
//        let userDocRef = db.collection("users").document(uid)
//        
//        // 1. Check if the user document already exists in Firestore
//        let document = try await userDocRef.getDocument()
//        
//        if document.exists {
//            // A. Existing User: Proceed with standard login (fetch user data)
//            print("Firestore user profile found. Logging in.")
//            let user = try document.data(as: AppUser.self)
//            
//            DispatchQueue.main.async {
//                self.currentUser = user
//            }
//            
//        } else {
//            // B. New User: Create the MINIMAL profile document
//            print("New social user. Creating minimal Firestore profile.")
//            
//            // --- Logic for Auto-Assigning Name ---
//            let emailPrefix = email.split(separator: "@").first.map { String($0) }
//            
//            let userData: [String: Any] = [
//                "email": email,
//                "role": role.rawValue, // Assign role during social sign-up flow
//                "created_at": Timestamp(),
//                "username": emailPrefix ?? "",
//                "full_name": emailPrefix ?? "",
//                "phone_number": nil as String?, // Explicitly set optional fields to nil
//                "store_id": nil as String?
//            ]
//            
//            do {
//                try await userDocRef.setData(userData)
//                // Decode the data you just wrote to set currentUser
//                let newUser = try AppUser(from: userData, uid: uid) // Custom initialiser/helper might be needed
//                
//                // For simplicity, re-fetch or construct the user object after writing
//                let createdDoc = try await userDocRef.getDocument()
//                let user = try createdDoc.data(as: AppUser.self)
//
//                DispatchQueue.main.async {
//                    self.currentUser = user
//                }
//            } catch {
//                throw AuthError.firestoreWriteError("Failed to create user profile: \(error.localizedDescription)")
//            }
//        }
//    }
//}
