//
//  ReviewModel.swift
//  QuickBite
//
//  Created by student on 03/12/25.
//

import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    // @DocumentID mengambil ID unik dokumen (contoh: "Aw18Bxb...")
    @DocumentID var id: String?
    
    var comment: String
    var rating: Int
    var ratePhotos: [String] // Array URL foto
    var orderID: String      // Menyimpan "/orders/0000..."
    var createdAt: Date      // Firestore Timestamp otomatis jadi Date
    
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case comment
        case rating
        
        // Mapping snake_case (Firebase) -> camelCase (Swift)
        case ratePhotos = "rate_photos"
        case orderID = "orders_id"
        case createdAt = "created_at"
    }
}
