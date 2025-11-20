//
//  SignInWithGoogleViewModel.swift
//  QuickBite
//
//  Created by Angela on 07/11/25.
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var isLoginSuccessed = false
    @Published var email = ""
    @Published var password = ""
    
    private let db = Firestore.firestore()
    
    // MARK: - Create Auth User
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // MARK: - SIGN UP (Email/Password + Firestore + Unique Username)
    func signUp(role: UserRole) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email or password missing."])
        }
        
        // 1. Create user in Firebase Auth
        let returnedUser = try await createUser(email: email, password: password)
        
        // 2. Create Firestore document with unique username
        try await createUserDocument(
            uid: returnedUser.uid,
            email: email,
            role: role
        )
        
        print("🔥 Successfully created user & Firestore document.")
    }
    
    // MARK: - Create Firestore Document with Unique Username
    private func createUserDocument(uid: String, email: String, role: UserRole) async throws {
        let uniqueUsername = try await generateUniqueUsername(from: email)
        
        let data: [String: Any] = [
            "email": email,
            "role": role.rawValue,
            "username": uniqueUsername,             // ✅ UNIQUE USERNAME
            "full_name": NSNull(),
            "phone_number": NSNull(),
            "store_id": NSNull(),
            "created_at": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(uid).setData(data, merge: true)
    }
    
    // MARK: - Unique Username Generator
    private func generateUniqueUsername(from email: String) async throws -> String {
        // base = part before "@", lowercase
        let base = email.components(separatedBy: "@").first?.lowercased() ?? "user"
        
        var candidate = base
        var suffix = 0
        
        while true {
            let query = db.collection("users").whereField("username", isEqualTo: candidate)
            let snapshot = try await query.getDocuments()
            
            if snapshot.documents.isEmpty {
                // nobody uses this username yet
                return candidate
            }
            
            // try next candidate: base1, base2, base3, ...
            suffix += 1
            candidate = "\(base)\(suffix)"
        }
    }
    
    // MARK: - EMAIL SIGN IN
    func signInWithEmailPassword() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter both email and password."])
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Signed in user: \(result.user.uid)")
            isLoginSuccessed = true
        } catch let error as NSError {
            print("Firebase error code: \(error.code)")
            
            switch AuthErrorCode(rawValue: error.code) {
            case .userNotFound:
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "This email is not registered."])
                
            case .wrongPassword, .invalidCredential:
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "The password you entered is incorrect."])
                
            case .invalidEmail:
                throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "The email address is invalid."])
                
            default:
                throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected error: \(error.localizedDescription)"])
            }
        }
    }
    
    // MARK: - GOOGLE SIGN IN (with unique username)
    func signInWithGoogle(role: UserRole? = nil) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController) { [weak self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let user = user?.user,
                let idToken = user.idToken
            else { return }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { res, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let firebaseUser = res?.user else { return }
                print("🔥 Google Sign-in: \(firebaseUser.uid)")
                
                self?.createMissingGoogleUserDocument(firebaseUser: firebaseUser, role: role)
            }
        }
    }
    
    private func createMissingGoogleUserDocument(firebaseUser: User, role: UserRole?) {
        Task {
            do {
                let docRef = db.collection("users").document(firebaseUser.uid)
                let snapshot = try await docRef.getDocument()
                
                if snapshot.exists {
                    print("📌 Google user doc exists, skip creation.")
                    return
                }
                
                let email = firebaseUser.email ?? ""
                let uniqueUsername = try await generateUniqueUsername(from: email)
                
                let data: [String: Any] = [
                    "email": email,
                    "username": uniqueUsername,                 // ✅ UNIQUE USERNAME
                    "role": role?.rawValue ?? "customer",      // default to customer
                    "full_name": NSNull(),
                    "phone_number": NSNull(),
                    "store_id": NSNull(),
                    "created_at": FieldValue.serverTimestamp()
                ]
                
                try await docRef.setData(data)
                print("🔥 Created Google user Firestore doc.")
            } catch {
                print("❌ Failed to create Google user Firestore doc: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
    
    // MARK: - Delete Account
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}
