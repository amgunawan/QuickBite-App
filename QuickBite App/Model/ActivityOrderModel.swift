import Foundation
import FirebaseFirestore

struct ActivityOrderModel: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: DocumentReference?
    var storeId: DocumentReference?
    var restaurantImageURL: String? // Field dari koleksi orders (jika ada)
    var mealName: String?
    var totalCost: Int
    var status: String
    var rating: Int?
    var createdAt: Date?
    var pickupTime: Date?
    
    // Variabel tambahan hasil fetch dari koleksi stores
    var restaurantName: String?
    var storeSearchImageURL: String? // Menampung hasil konversi gs:// ke https://

    var formattedDate: String {
        guard let date = createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, HH:mm"
        return formatter.string(from: date)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case storeId = "store_id"
        case restaurantImageURL = "restaurant_image_url"
        case mealName = "meal_name"
        case totalCost = "total_cost"
        case status
        case rating
        case createdAt = "created_at"
        case pickupTime = "pickup_time"
    }
}
