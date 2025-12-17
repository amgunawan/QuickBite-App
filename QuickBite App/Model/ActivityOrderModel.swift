import Foundation
import FirebaseFirestore

// MARK: - Order Item (SESUAI Firestore)
struct OrderItem: Codable {
    var itemId: String
    var price: Int
    var quantity: Int

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case price
        case quantity
    }
}


// MARK: - Activity Order Model
struct ActivityOrderModel: Identifiable, Codable {

    // Firestore document ID
    @DocumentID var id: String?

    // ===== FIELD YANG ADA DI FIRESTORE =====
    var userId: DocumentReference
    var storeId: DocumentReference
    var status: String
    var totalCost: Int
    var createdAt: Timestamp
    var pickupTime: Timestamp
    var items: [OrderItem]

    // Optional Firestore fields
    var orderType: String?
    var preptimeMin: Int?
    var preptimeMax: Int?
    var qrCode: String?

    // ===== UI ONLY (JANGAN MASUK CodingKeys) =====
    var restaurantName: String?
    var storeSearchImageURL: String?

    // ===== COMPUTED =====
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, HH:mm"
        return formatter.string(from: createdAt.dateValue())
    }
    
    var rating: Int?


    var itemSummary: String {
        "\(items.count) item(s)"
    }

    var mealSummary: String {
        items.map { "\($0.quantity)x \($0.itemId)" }.joined(separator: ", ")
    }

    // ===== CODING KEYS (1:1 DENGAN FIRESTORE) =====
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case storeId = "store_id"
        case status
        case totalCost = "total_cost"
        case createdAt = "created_at"
        case pickupTime = "pickup_time"
        case items
        case rating 
        case orderType = "order_type"
        case preptimeMin = "preptime_min"
        case preptimeMax = "preptime_max"
        case qrCode = "qr_code"
    }
}
