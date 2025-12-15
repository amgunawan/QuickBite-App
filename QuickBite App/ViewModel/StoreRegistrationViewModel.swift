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

    // MARK: - CORE STORE IDENTITY
    @Published var storeName: String = ""
    @Published var location: String = ""
    @Published var cuisineTypes: [String] = []

    // MARK: - BRANDING
    @Published var bannerImage: UIImage? = nil
    @Published var searchIcon: UIImage? = nil

    // MARK: - SCHEDULE
    @Published var openDays: Set<Weekday> = []
    @Published var openingTime: Date = Date()
    @Published var closingTime: Date = Date()

    // MARK: - MENU (NEW MODEL)
    @Published var menuSections: [MenuSectionModel] = []

    // MARK: - KTP
    @Published var ktpImage: UIImage? = nil

    // MARK: - PAYOUT
    @Published var payoutAccountHolder: String = ""
    @Published var payoutAccountNumber: String = ""
    @Published var payoutBankName: String = ""
    @Published var payoutNMID: String = ""

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - MAIN ENTRY POINT

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

        // 1️⃣ CREATE STORE DOCUMENT
        let storeRef = db.collection("stores").document()
        let storeID = storeRef.documentID

        // 2️⃣ UPLOAD IMAGES
        let bannerURL = try await uploadImage(
            bannerImage,
            path: "\(storeID)/main/banner.jpg"
        )

        let searchURL = try await uploadImage(
            searchIcon,
            path: "\(storeID)/main/search.jpg"
        )

        // 3️⃣ UPLOAD MENU.JSON + TRACKING
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

        // 5️⃣ SAVE STORE DOCUMENT
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

        // 6️⃣ LINK STORE TO USER
        try await db.collection("users")
            .document(uid)
            .updateData([
                "store_id": storeID,
                "onboarding_step": 8
            ])

        print("✅ STORE REGISTRATION COMPLETE")
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
    // MARK: - MENU JSON UPLOAD (ADAPTED TO EXISTING MODEL)
    // -----------------------------------------------------

    private func uploadMenuJSON(
        sections: [MenuSectionModel],
        storeID: String
    ) async throws -> (menuURL: String, trackingItems: [[String: Any]]) {

        var menuUploads: [MenuItemUploadModel] = []
        var trackingItems: [[String: Any]] = []

        for section in sections {
            for item in section.items {

                let upload = MenuItemUploadModel(
                    item_id: item.itemId,
                    name: item.name,
                    description: item.description ?? "",
                    price: item.price,
                    default_stock: item.defaultStock ?? 0,
                    prep_time_minutes: item.prepTimeMinutes ?? 0,
                    category: section.title,
                    image_url: item.imageURL ?? ""
                )

                menuUploads.append(upload)

                let tracking: [String: Any] = [
                    "item_id": item.itemId,
                    "current_stock": item.defaultStock ?? 0,
                    "total_sold": 0
                ]

                trackingItems.append(tracking)
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let data = try encoder.encode(menuUploads)
        let ref = storage.reference().child("\(storeID)/menu.json")

        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()

        return (menuURL: url.absoluteString, trackingItems: trackingItems)
    }

    // -----------------------------------------------------
    // MARK: - STORE SCHEDULE
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

    // -----------------------------------------------------
    // MARK: - UPDATE ONBOARDING STEP
    // -----------------------------------------------------

    func updateOnboardingStep(_ step: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "AUTH",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
        }

        try await db.collection("users")
            .document(uid)
            .updateData(["onboarding_step": step])
    }
}
