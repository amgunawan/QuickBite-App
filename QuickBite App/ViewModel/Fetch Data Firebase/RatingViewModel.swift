//
//  RatingViewModel.swift
//  QuickBite
//
//  Created by student on 09/12/25.
//

import Foundation
import FirebaseFirestore
import Combine

class TenantRatingViewModel: ObservableObject {
    @Published var averageRating: Double = 0.0
    @Published var totalReviews: Int = 0

    private let db = Firestore.firestore()

    func fetchRating(for storeId: String) {
        db.collection("reviews").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching reviews:", error.localizedDescription)
                return
            }

            guard let documents = snapshot?.documents else {
                print("❌ No reviews found")
                return
            }

            print("📄 Total reviews fetched:", documents.count)

            var ratingSum: Double = 0
            var reviewCount: Int = 0

            let group = DispatchGroup()

            for doc in documents {
                group.enter()

                let data = doc.data()
                let rating = data["rating"] as? Double ?? 0.0

                // MARK: 🚨 orders_id MUST be DocumentReference
                guard let orderRef = data["orders_id"] as? DocumentReference else {
                    print("⚠️ Review \(doc.documentID) missing orders_id reference")
                    group.leave()
                    continue
                }

                print("\n➡️ Checking review ID:", doc.documentID)
                print("   ↳ Rating:", rating)
                print("   ↳ OrderRef:", orderRef.path)

                orderRef.getDocument { orderSnap, err in
                    if let err = err {
                        print("❌ Failed to fetch order:", err.localizedDescription)
                        group.leave()
                        return
                    }

                    guard let orderData = orderSnap?.data() else {
                        print("⚠️ Order missing for review:", doc.documentID)
                        group.leave()
                        return
                    }

                    // MARK: 🚨 store_id MUST be DocumentReference
                    guard let storeRef = orderData["store_id"] as? DocumentReference else {
                        print("⚠️ Order for review \(doc.documentID) has no store_id reference")
                        group.leave()
                        return
                    }

                    print("   ↳ StoreRef:", storeRef.path)
                    print("   ↳ StoreRef.documentID:", storeRef.documentID)
                    print("   ↳ TARGET:", storeId)

                    // MARK: 🎯 Check if belongs to this store
                    if storeRef.documentID == storeId {
                        print("   ✅ MATCH → Rating counted:", rating)
                        ratingSum += rating
                        reviewCount += 1
                    } else {
                        print("   ❌ NOT MATCH → belongs to another store")
                    }

                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("✔️ Reviews Counted:", reviewCount)
                print("✔️ Rating Sum:", ratingSum)

                self.totalReviews = reviewCount
                self.averageRating = reviewCount > 0 ? (ratingSum / Double(reviewCount)) : 0.0
            }
        }
    }
}


