//
//  AppUser.swift
//  QuickBite
//
//  Created by Student on 19/11/25.
//

import Foundation
import FirebaseFirestore

enum UserRole: String, Codable {
    case customer
    case merchant
}

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    
    let email: String
    let role: UserRole
    let created_at: Timestamp?

    let full_name: String?
    let username: String
    let password: String
    let phone_number: String?
    let store_id: String?
}
