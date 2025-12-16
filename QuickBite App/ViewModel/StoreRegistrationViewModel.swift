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
    private let kStoreName = "draft_storeName"
    private let kLocation = "draft_location"
    private let kCuisine = "draft_cuisine"
    // Note: Saving complex objects like Images or Menu arrays requires more work (e.g. FileManager or CoreData),
    // but saving the Strings is enough to stop the specific empty name crash.

    init() {
        // When VM initializes, try to restore data
        restoreDraft()
    }

    // Call this whenever you want to save progress (e.g., when clicking Continue)
    func saveDraft() {
        UserDefaults.standard.set(storeName, forKey: kStoreName)
        UserDefaults.standard.set(location, forKey: kLocation)
        UserDefaults.standard.set(cuisineTypes, forKey: kCuisine)
        print("💾 Draft saved locally")
    }

    private func restoreDraft() {
        if let savedName = UserDefaults.standard.string(forKey: kStoreName) {
            self.storeName = savedName
        }
        if let savedLocation = UserDefaults.standard.string(forKey: kLocation) {
            self.location = savedLocation
        }
        if let savedCuisine = UserDefaults.standard.stringArray(forKey: kCuisine) {
            self.cuisineTypes = savedCuisine
        }
    }
    
    // Call this AFTER successful registration to clean up
    func clearDraft() {
        UserDefaults.standard.removeObject(forKey: kStoreName)
        UserDefaults.standard.removeObject(forKey: kLocation)
        UserDefaults.standard.removeObject(forKey: kCuisine)
    }

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
    ) async throws -> String {

        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AUTH", code: 401)
        }
        try await assertStoreNameIsUnique(storeName)
        
        let sanitizedStoreName = sanitizeStoreName(storeName)
        print("🟠 [RegisterStore] storeName received:", storeName)
        assert(
            !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            "❌ storeName is EMPTY at registration time"
        )

        // 1️⃣ CREATE STORE DOCUMENT
        let storeRef = db.collection("stores").document()
        let storeID = storeRef.documentID

        // 2️⃣ UPLOAD IMAGES
        let bannerURL = try await uploadImage(
            bannerImage,
            path: "\(sanitizedStoreName)/main/banner.jpg"
        )

        let searchURL = try await uploadImage(
            searchIcon,
            path: "\(sanitizedStoreName)/main/search.jpg"
        )

        // 3️⃣ UPLOAD MENU.JSON + TRACKING
        let (menuJSONURL, trackingItems) = try await uploadMenuJSON(
            sections: sections,
            storeID: storeID,
            storeName: sanitizedStoreName
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
            "sanitized_name": sanitizedStoreName,
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
//        try await db.collection("users")
//            .document(uid)
//            .updateData([
//                "store_id": storeID,
//                "onboarding_step": 8
//            ])

        print("✅ STORE REGISTRATION COMPLETE")
        
        return storeID
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
        storeID: String,
        storeName: String
    ) async throws -> (menuURL: String, trackingItems: [[String: Any]]) {

        var menuUploads: [MenuItemUploadModel] = []
        var trackingItems: [[String: Any]] = []

        // 🅰️ Store prefix (first letter, uppercase, spaces removed)
        let cleanStoreName = storeName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")

        let storePrefix = cleanStoreName.first.map {
            String($0).uppercased()
        } ?? "X"

        for section in sections {

            // 🅱️ Section prefix (first letter, uppercase, spaces removed)
            let cleanSectionName = section.title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "")

            let sectionPrefix = cleanSectionName.first.map {
                String($0).uppercased()
            } ?? "X"

            var itemIndex = 1   // 🔢 reset numbering per section

            for item in section.items {

                let formattedItemID = "\(storePrefix)\(sectionPrefix)\(itemIndex)"
                itemIndex += 1

                let upload = MenuItemUploadModel(
                    item_id: formattedItemID,
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
                    "item_id": formattedItemID,
                    "current_stock": item.defaultStock ?? 0,
                    "total_sold": 0
                ]

                trackingItems.append(tracking)
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let data = try encoder.encode(menuUploads)

        // 📁 Store folder name = store name without spaces
        let ref = storage.reference()
            .child("\(cleanStoreName)/menu.json")

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
    
    private func sanitizeStoreName(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
    }
    
    private func assertStoreNameIsUnique(_ storeName: String) async throws {
        let sanitized = sanitizeStoreName(storeName)

        let snapshot = try await db.collection("stores")
            .whereField("sanitized_name", isEqualTo: sanitized)
            .getDocuments()

        if !snapshot.documents.isEmpty {
            throw NSError(
                domain: "STORE_NAME_TAKEN",
                code: 409,
                userInfo: [
                    NSLocalizedDescriptionKey:
                    "Store name '\(storeName)' is already taken. Please choose another name."
                ]
            )
        }
    }
    
    private func generateItemId(
        storeName: String,
        sectionName: String,
        index: Int
    ) -> String {
        let storeInitial = storeName.first.map { String($0).uppercased() } ?? "X"
        let sectionInitial = sectionName.first.map { String($0).uppercased() } ?? "X"
        return "\(storeInitial)\(sectionInitial)\(index + 1)"
    }
}
