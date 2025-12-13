//
//  StoreRegistrationViewModel.swift
//  QuickBite
//
//  Created by student on 05/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit
import Combine

@MainActor
class StoreRegistrationViewModel: ObservableObject {

    // CORE STORE IDENTITY
//    @Published var username: String = FetchedResultsStore.shared.currentUser?.email ?? ""
    @Published var storeName: String = ""
    @Published var location: String = ""
    @Published var cuisineTypes: [String] = []

    // BRANDING
    @Published var bannerImage: UIImage? = nil
    @Published var searchIcon: UIImage? = nil

    // SCHEDULE
    @Published var openDays: Set<Weekday> = []
    @Published var openingTime: Date = Date()
    @Published var closingTime: Date = Date()

    // MENU
    @Published var menuSections: [MenuSectionModel] = []
    
    //KTP
    @Published var ktpImage: UIImage? = nil

    // PAYOUT
    @Published var payoutAccountHolder: String = ""
    @Published var payoutAccountNumber: String = ""
    @Published var payoutBankName: String = ""
    @Published var payoutNMID: String = ""
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // ✅ MAIN ENTRY POINT (called from Finish button later)
    func registerStore(
        storeName: String,
        location: String,
        cuisineTypes: [String],
        bannerImage: UIImage,
        searchIcon: UIImage,
        openDays: Set<Weekday>,
        openingTime: Date,
        closingTime: Date,
        sections: [MenuSectionModel]
    ) async throws {

        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AUTH", code: 401)
        }

        // 1️⃣ CREATE STORE DOCUMENT ID
        let storeRef = db.collection("stores").document()
        let storeID = storeRef.documentID

        // 2️⃣ UPLOAD IMAGES TO STORAGE (USING storeID)
        let bannerURL = try await uploadImage(
            bannerImage,
            path: "\(storeID)/main/banner.jpg"
        )

        let searchURL = try await uploadImage(
            searchIcon,
            path: "\(storeID)/main/search.jpg"
        )

        // 3️⃣ UPLOAD MENU.JSON
        let (menuJSONURL, trackingItems) = try await uploadMenuJSON(
            sections: sections,
            storeID: storeID
        )

        // 4️⃣ GENERATE SCHEDULE
        let schedule = generateSchedule(
            openDays: openDays,
            openingTime: openingTime,
            closingTime: closingTime
        )

//        // 5️⃣ GENERATE TRACKING ITEMS
//        let trackingItems = generateTrackingItems(from: sections)

        // 6️⃣ SAVE STORE DOCUMENT
        let storeData: [String: Any] = [
            "owner_id": uid,                   
            "name": storeName,
            "location": location,
            "cuisine_type": cuisineTypes,
            "banner_url": bannerURL,
            "search_url": searchURL,
            "menu_data_url": menuJSONURL,
            "rating": 0,
            "review_count": 0,
            "store_schedule": schedule,
            "tracking_item": trackingItems,
            "payout_details": [
                "account_holder": payoutAccountHolder,
                "account_number": payoutAccountNumber,
                "bank_name": payoutBankName,
                "nmid": payoutNMID
            ]
        ]

        try await storeRef.setData(storeData)

        // 7️⃣ LINK STORE TO USER
        try await db.collection("users")
            .document(uid)
            .updateData([
                "store_id": storeID
            ])

        print("✅ STORE + USER LINKED SUCCESSFULLY")
    }


    // -----------------------------------------------------
    // MARK: - IMAGE UPLOAD
    // -----------------------------------------------------

    private func uploadImage(_ image: UIImage, path: String) async throws -> String {

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "IMG", code: 500)
        }

        let ref = storage.reference().child(path)

        _ = try await ref.putDataAsync(data)

        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    // -----------------------------------------------------
    // MARK: - MENU JSON UPLOAD
    // -----------------------------------------------------

    private func uploadMenuJSON(
        sections: [MenuSectionModel],
        storeID: String
    ) async throws -> (menuURL: String, trackingItems: [[String: Any]]) {

        // Build flatItems and reuse the same item_id for tracking
        var flatItems: [MenuItemUploadModel] = []
        var trackingItems: [[String: Any]] = []

        for section in sections {
            for item in section.items {
                // Use deterministic ID: UUID here (or you can use custom)
                let itemUUID = UUID().uuidString

                let upload = MenuItemUploadModel(
                    item_id: itemUUID,
                    name: item.name,
                    description: item.description,
                    price: item.price,
                    default_stock: item.defaultStock,
                    prep_time_minutes: item.prepTimeMinutes,
                    category: section.title,
                    image_url: item.imageURL
                )
                flatItems.append(upload)

                // Generate tracking item using same item_id
                let tracking: [String: Any] = [
                    "item_id": itemUUID,
                    "current_stock": item.defaultStock,
                    "total_sold": 0
                ]
                trackingItems.append(tracking)
            }
        }

        let data = try JSONEncoder().encode(flatItems)
        let ref = storage.reference().child("\(storeID)/menu.json")
        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()
        return (menuURL: url.absoluteString, trackingItems: trackingItems)
    }

    // -----------------------------------------------------
    // MARK: - STORE SCHEDULE GENERATOR
    // -----------------------------------------------------

    private func generateSchedule(
        openDays: Set<Weekday>,
        openingTime: Date,
        closingTime: Date
    ) -> [String: Any] {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let open = formatter.string(from: openingTime)
        let close = formatter.string(from: closingTime)

        var schedule: [String: Any] = [:]

        for day in openDays {
            schedule[day.rawValue] = [
                "open_time": open,
                "close_time": close
            ]
        }

        return schedule
    }
//
//    // -----------------------------------------------------
//    // MARK: - TRACKING ITEM GENERATOR
//    // -----------------------------------------------------
//
//    private func generateTrackingItems(from sections: [MenuSectionModel]) -> [[String: Any]] {
//
//        sections.flatMap { section in
//            section.items.map { item in
//                [
//                    "item_id": UUID().uuidString,
//                    "current_stock": item.stock,
//                    "total_sold": 0
//                ]
//            }
//        }
//    }
}
