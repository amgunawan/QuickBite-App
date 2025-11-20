//
//  AuthDataResultModel.swift
//  QuickBite
//
//  Created by Angela on 07/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct AuthDataResultModel: Codable {
    let uid: String
    let email: String?
    let photoURL: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}
