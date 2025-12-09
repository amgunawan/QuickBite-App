//
//  TenantUser.swift
//  QuickBite
//
//  Created by student on 09/12/25.
//

import Foundation
import FirebaseFirestore

struct TenantUser: Identifiable, Codable {
    @DocumentID var id: String?          // id dokumen user (uid)
    
    var email: String
    var fullName: String
    var phoneNumber: String
    var username: String
    var role: String
    var storeId: String?                 // "2plb4UCwxjle2Yy6PTdj"
    var language: String?                // optional (bisa belum ada di Firestore)

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName     = "full_name"
        case phoneNumber  = "phone_number"
        case username
        case role
        case storeId      = "store_id"
        case language
    }
}
