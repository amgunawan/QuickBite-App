//
//  UserModel.swift
//  QuickBite App
//
//  Created by Angela on 17/12/25.
//


import Foundation
import FirebaseFirestore

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    let username: String
    let email: String
    var full_name: String?
}
