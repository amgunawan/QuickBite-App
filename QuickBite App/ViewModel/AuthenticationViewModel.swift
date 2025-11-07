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
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var isLoginSuccessed = false
    @Published var email = ""
    @Published var password = ""
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        Task {
            do {
                let returnedUserData = try await createUser(email: email, password: password)
                print("Signed up user: \(returnedUserData)")
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    
    func signInWithEmailPassword() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please enter both email and password."])
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Signed in user: \(result.user.uid)")
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
                print("⚠️ Unhandled Firebase error: \(error.localizedDescription)")
                throw NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unexpected error: \(error.localizedDescription)"])
            }
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController) { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let user = user?.user,
                let idToken = user.idToken else { return }
            
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { res, error in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                guard let user = res?.user else { return }
                print(user)
            }
        }
    }
    
    func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
   
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await user.delete()
    }
}
