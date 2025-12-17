//
//  AuthenticationViewModel.swift
//  QuickBite
//
// 
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

// MARK: - Firestore Field Constants
enum FirestoreUserFields {
    static let email = "email"
    static let role = "role"
    static let username = "username"
    static let fullName = "full_name"
    static let phoneNumber = "phone_number"
    static let storeId = "store_id"
    static let onboardingStep = "onboarding_step"
    static let createdAt = "created_at"
}

// MARK: - Session Model
struct AppUserSession {
    let uid: String
    let email: String
    var role: UserRole
    var onboardingStep: Int
    var storeId: String?
}

// MARK: - Authentication ViewModel
@MainActor
class AuthenticationViewModel: ObservableObject {

    // MARK: - Published UI State
    @Published var isLoginSuccessed: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - Live Session
    @Published var currentUserSession: AppUserSession?
    
    @Published var awaitingEmailVerification: Bool = false

    // MARK: - Private
    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    // MARK: - Init
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
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            Task {
                guard let user else {
                    self.currentUserSession = nil
                    self.awaitingEmailVerification = false
                    return
                }

                if !user.isEmailVerified {
                    self.currentUserSession = nil
                    self.awaitingEmailVerification = true
                    return
                }

                // ✅ VERIFIED
                self.awaitingEmailVerification = false

                do {
                    try await self.loadCurrentUser(uid: user.uid)
                } catch {
                    self.currentUserSession = nil
                }
            }
        }
    }
    
    // MARK: - Email Verification Cooldown
    @Published var resendCooldownRemaining: Int = 0
    private var resendTimer: Timer?
    private var lastVerificationSentAt: Date?

    var canResendVerification: Bool {
        resendCooldownRemaining == 0
    }

    // MARK: - Resend Verification Email
    func resendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AUTH", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Please sign in again."
            ])
        }

        guard canResendVerification else { return }

        try await user.sendEmailVerification()
        startResendCooldown()
    }

    private func startResendCooldown() {
        resendCooldownRemaining = 60
        resendTimer?.invalidate()

        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            resendCooldownRemaining -= 1
            if resendCooldownRemaining <= 0 {
                timer.invalidate()
                resendCooldownRemaining = 0
            }
        }
    }

    // MARK: - Create Auth User (Wrapper)
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authResult = try await Auth.auth()
            .createUser(withEmail: email, password: password)

        // ✅ SEND VERIFICATION WHILE USER OBJECT IS AVAILABLE
        try await authResult.user.sendEmailVerification()

        return AuthDataResultModel(user: authResult.user)
    }

    // MARK: - SIGN UP (Email / Password)
    func signUp(role: UserRole) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "AUTH", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Email or password missing."
            ])
        }

        let returnedUser = try await createUser(email: email, password: password)

        try await createUserDocument(
            uid: returnedUser.uid,
            email: email,
            role: role
        )

        // 🚫 Prevent auto-login
        try Auth.auth().signOut()

        // ✅ Trigger verification screen
        awaitingEmailVerification = true
    }

    // MARK: - Create Firestore User Document
    private func createUserDocument(
        uid: String,
        email: String,
        role: UserRole
    ) async throws {

        let uniqueUsername = try await generateUniqueUsername(from: email)
        let initialStep = (role == .merchant) ? 1 : 999

        let data: [String: Any] = [
            FirestoreUserFields.email: email,
            FirestoreUserFields.role: role.rawValue,
            FirestoreUserFields.username: uniqueUsername,
            FirestoreUserFields.fullName: NSNull(),
            FirestoreUserFields.phoneNumber: NSNull(),
            FirestoreUserFields.storeId: NSNull(),
            FirestoreUserFields.onboardingStep: initialStep,
            FirestoreUserFields.createdAt: FieldValue.serverTimestamp()
        ]

        try await db.collection("users")
            .document(uid)
            .setData(data, merge: true)
    }

    // MARK: - SIGN IN (Email / Password)
    func signInWithEmailPassword() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "AUTH", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "Please enter both email and password."
            ])
        }

        do {
            let result = try await Auth.auth()
                .signIn(withEmail: email, password: password)

            // 🚫 Verification check belongs HERE
            guard result.user.isEmailVerified else {
                try await result.user.sendEmailVerification()
                try Auth.auth().signOut()

                throw NSError(domain: "AUTH", code: 403, userInfo: [
                    NSLocalizedDescriptionKey:
                    "Please verify your email before signing in. A verification email has been sent."
                ])
            }

            // ✅ Do NOT load Firestore here
            // AuthStateListener will hydrate session

        } catch let error as NSError {

            switch AuthErrorCode(rawValue: error.code) {

            case .userNotFound:
                throw NSError(domain: "AUTH", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "This email is not registered."
                ])

            case .wrongPassword, .invalidCredential:
                throw NSError(domain: "AUTH", code: 401, userInfo: [
                    NSLocalizedDescriptionKey: "Incorrect password."
                ])

            case .invalidEmail:
                throw NSError(domain: "AUTH", code: 400, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid email format."
                ])

            default:
                throw error
            }
        }
    }

    // MARK: - Load Current User Session (SINGLE SOURCE OF TRUTH)
    func loadCurrentUser(uid: String) async throws -> AppUserSession {
        let snap = try await db.collection("users")
            .document(uid)
            .getDocument()

        guard let data = snap.data() else {
            throw NSError(domain: "FIRESTORE", code: 404)
        }

        let email = data[FirestoreUserFields.email] as? String ?? ""
        let roleRaw = data[FirestoreUserFields.role] as? String ?? UserRole.customer.rawValue
        let role = UserRole(rawValue: roleRaw) ?? .customer
        let onboardingStep = data[FirestoreUserFields.onboardingStep] as? Int ?? 999
        let storeId = data[FirestoreUserFields.storeId] as? String

        let session = AppUserSession(
            uid: uid,
            email: email,
            role: role,
            onboardingStep: onboardingStep,
            storeId: storeId
        )

        self.currentUserSession = session
        return session
    }

    // MARK: - Update Onboarding Step
    func updateOnboardingStep(_ step: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        try await db.collection("users")
            .document(uid)
            .updateData([
                FirestoreUserFields.onboardingStep: step
            ])

        if var session = currentUserSession {
            session.onboardingStep = step
            currentUserSession = session
        }
    }

    // MARK: - Finalize Merchant Onboarding
    func finalizeMerchantOnboarding(storeId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AUTH", code: 401)
        }

        try await db.collection("users")
            .document(uid)
            .updateData([
                FirestoreUserFields.storeId: storeId,
                FirestoreUserFields.onboardingStep: 8
            ])

        if var session = currentUserSession {
            session.storeId = storeId
            session.onboardingStep = 8
            currentUserSession = session
        }
    }

    // MARK: - GOOGLE SIGN IN
    func signInWithGoogle(role: UserRole? = nil) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(
            withPresenting: Application_utility.rootViewController
        ) { [weak self] user, error in

            if let error {
                print(error.localizedDescription)
                return
            }

            guard
                let self,
                let firebaseUser = user?.user,
                let idToken = firebaseUser.idToken
            else { return }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: firebaseUser.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, _ in
                Task {
                    try await self.createMissingGoogleUserDocument(
                        firebaseUser: Auth.auth().currentUser!,
                        role: role
                    )
                }
            }
        }
    }

    private func createMissingGoogleUserDocument(
        firebaseUser: User,
        role: UserRole?
    ) async throws {

        let docRef = db.collection("users").document(firebaseUser.uid)
        let snap = try await docRef.getDocument()

        if snap.exists {
            try await loadCurrentUser(uid: firebaseUser.uid)
            return
        }

        let email = firebaseUser.email ?? ""
        let username = try await generateUniqueUsername(from: email)
        let finalRole = role ?? .customer
        let step = (finalRole == .merchant) ? 1 : 999

        let data: [String: Any] = [
            FirestoreUserFields.email: email,
            FirestoreUserFields.username: username,
            FirestoreUserFields.role: finalRole.rawValue,
            FirestoreUserFields.storeId: NSNull(),
            FirestoreUserFields.onboardingStep: step,
            FirestoreUserFields.createdAt: FieldValue.serverTimestamp()
        ]

        try await docRef.setData(data)
        try await loadCurrentUser(uid: firebaseUser.uid)
    }

    // MARK: - Username Generator
    private func generateUniqueUsername(from email: String) async throws -> String {
        let base = email.components(separatedBy: "@").first?.lowercased() ?? "user"
        var candidate = base
        var suffix = 0

        while true {
            let snap = try await db.collection("users")
                .whereField(FirestoreUserFields.username, isEqualTo: candidate)
                .getDocuments()

            if snap.documents.isEmpty {
                return candidate
            }

            suffix += 1
            candidate = "\(base)\(suffix)"
        }
    }

    // MARK: - Sign Out
    func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
        currentUserSession = nil
    }

    // MARK: - Delete Account
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AUTH", code: 401)
        }

        try await db.collection("users")
            .document(user.uid)
            .delete()

        try await user.delete()

        currentUserSession = nil
    }
    
    // MARK: - Reset Auth Form Fields
    func resetCredentials() {
        email = ""
        password = ""
    }
    
    // MARK: - Refresh Email Verification Status (SINGLE SOURCE OF TRUTH)
    func refreshEmailVerificationStatus() async {
        guard let user = Auth.auth().currentUser else { return }

        do {
            try await user.reload()

            if user.isEmailVerified {
                awaitingEmailVerification = false
                try await loadCurrentUser(uid: user.uid)
            } else {
                awaitingEmailVerification = true
            }

        } catch {
            print("Failed to refresh verification status:", error.localizedDescription)
        }
    }
}
