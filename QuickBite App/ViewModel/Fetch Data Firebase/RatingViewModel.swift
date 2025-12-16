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

            for doc in documents {
                let data = doc.data()
                let rating = data["rating"] as? Double ?? 0.0
                let reviewStoreId = data["store_id"] as? String ?? ""

                print("\n➡️ Checking review ID:", doc.documentID)
                print("   ↳ Rating:", rating)
                print("   ↳ ReviewStoreId:", reviewStoreId)
                print("   ↳ TARGET StoreId:", storeId)

                if reviewStoreId == storeId {
                    print("   ✅ MATCH → Rating counted:", rating)
                    ratingSum += rating
                    reviewCount += 1
                } else {
                    print("   ❌ NOT MATCH → belongs to another store")
                }
            }

            print("✔️ Reviews Counted:", reviewCount)
            print("✔️ Rating Sum:", ratingSum)

            self.totalReviews = reviewCount
            self.averageRating = reviewCount > 0 ? (ratingSum / Double(reviewCount)) : 0.0
        }
    }
}
