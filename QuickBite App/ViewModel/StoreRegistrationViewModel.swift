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
    
    // MARK: - DRAFT
    private let kStoreName = "draft_storeName"
    private let kLocation = "draft_location"
    private let kCuisine = "draft_cuisine"
    
    init() {
        restoreDraft()
    }

    // MARK: - MAIN ENTRY POINT

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

        let sanitizedStoreName = sanitizeFolderName(storeName)

        // 1️⃣ CREATE STORE DOC
        let storeRef = db.collection("stores").document()
        let storeID = storeRef.documentID

        // 2️⃣ UPLOAD MAIN IMAGES
        let resizedBanner = ImageResizeHelper.resize(
            bannerImage,
            mode: .ratio16x9,
            maxSize: 1600
        )

        let bannerURL = try await uploadImage(
            resizedBanner,
            path: "\(sanitizedStoreName)/main/banner.jpg"
        )

        let searchURL = try await uploadImageToStorage(
            searchIcon,
            path: "\(sanitizedStoreName)/main/search.jpg"
        )

        // 3️⃣ UPLOAD ITEM IMAGES
        var preparedSections = sections

        for secIndex in preparedSections.indices {
            let section = preparedSections[secIndex]
            let sanitizedCategory = sanitizeFolderName(section.title)

            for itemIndex in section.items.indices {
                var item = section.items[itemIndex]

                guard let image = item.draftImage else { continue }
                
                let squareImage = ImageResizeHelper.resize(
                    image,
                    mode: .square,
                    maxSize: 800
                )

                let path = "\(sanitizedStoreName)/\(sanitizedCategory)/\(item.itemId).jpg"

                let uploadedURL = try await uploadImageToStorage(squareImage, path: path)
                item.imageURL = uploadedURL
                item.draftImage = nil

                preparedSections[secIndex].items[itemIndex] = item
            }
        }

        // 4️⃣ UPLOAD MENU.JSON
        let menuURL = try await uploadMenuJSON(
            sections: preparedSections,
            sanitizedStoreName: sanitizedStoreName
        )

        // 5️⃣ GENERATE SCHEDULE
        let schedule = generateSchedule(
            openDays: openDays,
            openingTime: openingTime,
            closingTime: closingTime
        )

        // 6️⃣ SAVE STORE DOCUMENT
        let storeData: [String: Any] = [
            "owner_id": uid,
            "name": storeName,
            "sanitized_name": sanitizedStoreName,
            "location": location,
            "cuisine_type": cuisineTypes,
            "banner_url": bannerURL,
            "search_url": searchURL,
            "menu_data_url": menuURL,
            "rating": 0,
            "review_count": 0,
            "store_schedule": schedule
        ]

        try await storeRef.setData(storeData)

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

    func uploadMenuJSON(
        sections: [MenuSectionModel],
        sanitizedStoreName: String
    ) async throws -> String {

        let allItems = sections.flatMap { $0.items }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let data = try encoder.encode(allItems)

        let ref = Storage.storage()
            .reference()
            .child("\(sanitizedStoreName)/menu.json")

        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()

        return url.absoluteString
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
