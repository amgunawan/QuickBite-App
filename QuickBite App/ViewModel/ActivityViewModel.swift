import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine

final class ActivityViewModel: ObservableObject {

    @Published var progressOrders: [ActivityOrderModel] = []
    @Published var historyOrders: [ActivityOrderModel] = []
    @Published var ratedOrderIds: Set<String> = []

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - FETCH ORDERS
    func fetchOrders(for userId: String) {

        let userRef = db.collection("users").document(userId)

        db.collection("orders")
            .whereField("user_id", isEqualTo: userRef)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ Firestore error:", error.localizedDescription)
                    return
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.progressOrders = []
                        self.historyOrders = []
                    }
                    return
                }

                var orders: [ActivityOrderModel] = []

                // 1️⃣ Decode orders (STRICT sesuai database)
                for doc in documents {
                    do {
                        let order = try doc.data(as: ActivityOrderModel.self)
                        orders.append(order)
                    } catch {
                        print("❌ Decode error:", error)
                    }
                }

                let group = DispatchGroup()

                // 2️⃣ Fetch store data (name + image)
                for i in orders.indices {
                    let storeRef = orders[i].storeId

                    group.enter()
                    storeRef.getDocument { storeDoc, _ in
                        defer { group.leave() }

                        guard let data = storeDoc?.data() else { return }

                        // Store name
                        orders[i].restaurantName = data["name"] as? String

                        // Store image (gs:// → https://)
                        if let gsURL = data["search_url"] as? String {
                            let ref = self.storage.reference(forURL: gsURL)
                            ref.downloadURL { url, _ in
                                orders[i].storeSearchImageURL = url?.absoluteString
                            }
                        }
                    }
                }

                // 3️⃣ Update UI
                group.notify(queue: .main) {
                    self.progressOrders = orders.filter {
                        $0.status.lowercased() == "pending" ||
                        $0.status.lowercased() == "ready"
                    }

                    self.historyOrders = orders.filter {
                        $0.status.lowercased() == "completed"
                    }
                }
            }
    }
    
    func fetchRatedOrders() {
        db.collection("reviews")
            .addSnapshotListener { snapshot, _ in
                let ids = snapshot?.documents.compactMap { doc -> String? in
                    let data = doc.data()
                    if let orderRef = data["orders_id"] as? DocumentReference {
                        return orderRef.documentID
                    }
                    return nil
                } ?? []

                DispatchQueue.main.async {
                    self.ratedOrderIds = Set(ids)
                }
            }
    }


    // MARK: - UPDATE RATING
    func updateRating(orderId: String, rating: Int) {
        db.collection("orders")
            .document(orderId)
            .updateData([
                "rating": rating
            ])
    }
}
