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

// Minimal AppUser session model used by views/router
struct AppUserSession {
    let uid: String
    let email: String
    var role: UserRole
    var onboardingStep: Int
    var storeId: String?
}

class AuthenticationViewModel: ObservableObject {
    @Published var isLoginSuccessed = false
    @Published var email = ""
    @Published var password = ""
    
    // The live session derived from Firestore user doc (nil when not signed in)
    @Published var currentUserSession: AppUserSession?

    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Attach listener so app can react to sign-in / sign-out
        attachAuthStateListener()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth state listener
    private func attachAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Task { @MainActor in
                guard let self = self else { return }
                if let user = user {
                    // load Firestore user doc to populate session
                    do {
                        try await self.loadCurrentUser(uid: user.uid)
                    } catch {
                        // If loading fails, clear session and optionally sign out
                        print("Failed to load current user: \(error.localizedDescription)")
                        self.currentUserSession = nil
                    }
                } else {
                    // Signed out
                    self.currentUserSession = nil
                }
            }
        }
    }

    // MARK: - Create Auth User (thin wrapper)
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    // MARK: - SIGN UP (Email/Password + Firestore + Unique Username)
    // Keep behavior similar to previous but ensure session is loaded afterwards
    func signUp(role: UserRole) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email or password missing."])
        }

        let returnedUser = try await createUser(email: email, password: password)

        try await createUserDocument(
            uid: returnedUser.uid,
            email: email,
            role: role
        )

        // load user session immediately (no need to wait for verification if you disabled it)
        try await loadCurrentUser(uid: returnedUser.uid)

        print("🔥 Successfully created user & Firestore document.")
    }

    // MARK: - Create Firestore Document with Unique Username
    private func createUserDocument(uid: String, email: String, role: UserRole) async throws {
        let uniqueUsername = try await generateUniqueUsername(from: email)

        let initialOnboardingStep: Int = (role == .merchant) ? 1 : 999

        let data: [String: Any] = [
            "email": email,
            "role": role.rawValue,
            "username": uniqueUsername,
            "full_name": NSNull(),
            "phone_number": NSNull(),
            "store_id": NSNull(),
            "onboarding_step": initialOnboardingStep,
            "created_at": FieldValue.serverTimestamp()
        ]

        try await db.collection("users").document(uid).setData(data, merge: true)
    }

    // MARK: - Unique Username Generator (unchanged)
    private func generateUniqueUsername(from email: String) async throws -> String {
        let base = email.components(separatedBy: "@").first?.lowercased() ?? "user"

        var candidate = base
        var suffix = 0

        while true {
            let query = db.collection("users").whereField("username", isEqualTo: candidate)
            let snapshot = try await query.getDocuments()

            if snapshot.documents.isEmpty {
                return candidate
            }

            suffix += 1
            candidate = "\(base)\(suffix)"
        }
    }

    // MARK: - SIGN IN (Email)
    func signInWithEmailPassword() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter both email and password."])
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Signed in user: \(result.user.uid)")
            // Load Firestore user doc to populate session
            try await loadCurrentUser(uid: result.user.uid)
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

    // MARK: - Load current user Firestore doc and populate session
    func loadCurrentUser(uid: String) async throws -> AppUserSession {
        let docRef = db.collection("users").document(uid)
        let snap = try await docRef.getDocument()

        guard let data = snap.data() else {
            throw NSError(domain: "FIRESTORE", code: 404, userInfo: [NSLocalizedDescriptionKey: "User doc not found"])
        }

        let email = data["email"] as? String ?? Auth.auth().currentUser?.email ?? ""
        let roleRaw = data["role"] as? String ?? UserRole.customer.rawValue
        let role = UserRole(rawValue: roleRaw) ?? .customer
        let onboardingStep = data["onboarding_step"] as? Int ?? (role == .merchant ? 1 : 999)
        let storeId = data["store_id"] as? String

        let session = AppUserSession(uid: uid, email: email, role: role, onboardingStep: onboardingStep, storeId: storeId)

        await MainActor.run {
            self.currentUserSession = session
        }

        return session
    }

    // MARK: - Update onboarding step (updates Firestore AND local session)
    func updateOnboardingStep(_ step: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AUTH", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        try await db.collection("users").document(uid).updateData([
            "onboarding_step": step
        ])

        // reflect locally (if session exists)
        await MainActor.run {
            if var s = self.currentUserSession {
                s.onboardingStep = step
                self.currentUserSession = s
            }
        }
    }
    
    // MARK: - Finalize Merchant Onboarding
        func finalizeMerchantOnboarding(storeId: String) async throws {
            guard let uid = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "AUTH", code: 401)
            }

            // 1. Update Firestore
            try await db.collection("users")
                .document(uid)
                .updateData([
                    "store_id": storeId,
                    "onboarding_step": 8
                ])

            // 2. Update Local Session INSTANTLY (Don't wait for loadCurrentUser)
            await MainActor.run {
                if var current = self.currentUserSession {
                    current.storeId = storeId
                    current.onboardingStep = 8 // Force the step to 8
                    self.currentUserSession = current
                    print("✅ Local session updated to Step 8. Redirecting...")
                }
            }
        }

    // MARK: - GOOGLE SIGN IN (unchanged, but load session if needed)
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
                    // ensure session is loaded
                    try await loadCurrentUser(uid: firebaseUser.uid)
                    return
                }

                let email = firebaseUser.email ?? ""
                let uniqueUsername = try await generateUniqueUsername(from: email)

                let userRole: UserRole = role ?? .customer
                let initialOnboardingStep: Int = (userRole == .merchant) ? 1 : 999

                let data: [String: Any] = [
                    "email": email,
                    "username": uniqueUsername,
                    "role": userRole.rawValue,
                    "full_name": NSNull(),
                    "phone_number": NSNull(),
                    "store_id": NSNull(),
                    "onboarding_step": initialOnboardingStep,
                    "created_at": FieldValue.serverTimestamp()
                ]

                try await docRef.setData(data)
                try await loadCurrentUser(uid: firebaseUser.uid)
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
        await MainActor.run {
            self.currentUserSession = nil
        }
    }

    // MARK: - Delete Account
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
        await MainActor.run {
            self.currentUserSession = nil
        }
    }
}
