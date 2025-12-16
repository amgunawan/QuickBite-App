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
    @Published var currentUserSession: AppUserSession?

    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        attachAuthStateListener()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Listener
    private func attachAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Task { @MainActor in
                guard let self = self else { return }
                if let user = user {
                    do {
                        let session = try await self.loadCurrentUser(uid: user.uid)
                        self.currentUserSession = session
                    } catch {
                        print("Failed to load current user: \(error.localizedDescription)")
                        self.currentUserSession = nil
                    }
                } else {
                    self.currentUserSession = nil
                }
            }
        }
    }

    // MARK: - Create Auth User
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    // MARK: - Sign Up
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

        let session = try await loadCurrentUser(uid: returnedUser.uid)
        await MainActor.run {
            self.currentUserSession = session
        }

        print("🔥 Successfully created user & Firestore document.")
    }

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

    private func generateUniqueUsername(from email: String) async throws -> String {
        let base = email.components(separatedBy: "@").first?.lowercased() ?? "user"
        var candidate = base
        var suffix = 0

        while true {
            let snapshot = try await db.collection("users")
                .whereField("username", isEqualTo: candidate)
                .getDocuments()

            if snapshot.documents.isEmpty {
                return candidate
            }

            suffix += 1
            candidate = "\(base)\(suffix)"
        }
    }

    // MARK: - Sign In
    func signInWithEmailPassword() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter both email and password."])
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let session = try await loadCurrentUser(uid: result.user.uid)
            await MainActor.run {
                self.currentUserSession = session
                self.isLoginSuccessed = true
            }
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

    // MARK: - Load Current User
    @discardableResult
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

    // MARK: - Update Onboarding Step
    func updateOnboardingStep(_ step: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AUTH", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        try await db.collection("users").document(uid).updateData([
            "onboarding_step": step
        ])

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
        guard let user = Auth.auth().currentUser else { throw URLError(.badURL) }
        try await user.delete()
        await MainActor.run {
            self.currentUserSession = nil
        }
    }

    // MARK: - Google Sign In (unchanged)
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
}
