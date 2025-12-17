//
//  EditStoreDetailsViewModel.swift
//  QuickBite
//
//  Created by student on 17/12/25.
//

import FirebaseFirestore
import FirebaseStorage
import UIKit
import Combine

@MainActor
class EditStoreDetailsViewModel: ObservableObject {

    // MARK: - STATE
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - LOAD EXISTING STORE DATA

    func loadStore(
        storeId: String,
        completion: @escaping (StoreEditData) -> Void
    ) {
        isLoading = true

        db.collection("stores")
            .document(storeId)
            .getDocument { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false

                guard
                    let snapshot,
                    let data = snapshot.data(),
                    error == nil
                else {
                    self.errorMessage = "Failed to load store data."
                    return
                }

                Task {
                    let banner = await self.loadImage(from: data["banner_url"] as? String)
                    let icon = await self.loadImage(from: data["search_url"] as? String)

                    // ✅ RAW SCHEDULE — DO NOT PARSE HERE
                    let rawSchedule = data["store_schedule"] as? [String: Any]

                    completion(
                        StoreEditData(
                            banner: banner,
                            icon: icon,
                            rawSchedule: rawSchedule
                        )
                    )
                }
            }
    }

    // MARK: - SAVE CHANGES

    func saveChanges(
        storeId: String,
        bannerImage: UIImage?,
        iconImage: UIImage?,
        openDays: Set<Weekday>,
        openingTime: Date,
        closingTime: Date,
        open24Hours: Bool
    ) async {

        isSaving = true
        defer { isSaving = false }

        do {
            var updates: [String: Any] = [:]

            // === BANNER ===
            if let bannerImage {
                let resized = ImageResizeHelper.resize(
                    bannerImage,
                    mode: .ratio16x9,
                    maxSize: 1600
                )

                let url = try await uploadImage(
                    resized,
                    path: "stores/\(storeId)/banner.jpg"
                )

                updates["banner_url"] = url
            }

            // === SEARCH ICON ===
            if let iconImage {
                let resized = ImageResizeHelper.resize(
                    iconImage,
                    mode: .square,
                    maxSize: 800
                )

                let url = try await uploadImage(
                    resized,
                    path: "stores/\(storeId)/search.jpg"
                )

                updates["search_url"] = url
            }

            // === SCHEDULE ===
            let schedule = generateSchedule(
                openDays: openDays,
                openingTime: openingTime,
                closingTime: closingTime,
                open24Hours: open24Hours
            )

            updates["store_schedule"] = schedule

            try await db.collection("stores")
                .document(storeId)
                .updateData(updates)

        } catch {
            errorMessage = "Failed to save store changes."
            print("❌ Store update error:", error)
        }
    }

    // -----------------------------------------------------
    // MARK: - HELPERS
    // -----------------------------------------------------

    private func uploadImage(
        _ image: UIImage,
        path: String
    ) async throws -> String {

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "IMG", code: 500)
        }

        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(data)

        return "gs://\(ref.bucket)/\(ref.fullPath)"
    }

    private func loadImage(from gsURL: String?) async -> UIImage? {
        guard let gsURL else { return nil }

        let ref = storage.reference(forURL: gsURL)

        do {
            let data = try await ref.data(maxSize: 6 * 1024 * 1024)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    // -----------------------------------------------------
    // MARK: - SCHEDULE GENERATION
    // -----------------------------------------------------

    private func generateSchedule(
        openDays: Set<Weekday>,
        openingTime: Date,
        closingTime: Date,
        open24Hours: Bool
    ) -> [String: Any] {

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let open = formatter.string(from: openingTime)
        let close = formatter.string(from: closingTime)

        var schedule: [String: Any] = [:]

        for day in openDays {
            schedule[day.rawValue] = [
                "open_time": open24Hours ? "00:00" : open,
                "close_time": open24Hours ? "23:59" : close
            ]
        }

        return schedule
    }
}

// -----------------------------------------------------
// MARK: - DATA MODEL
// -----------------------------------------------------

struct StoreEditData {
    let banner: UIImage?
    let icon: UIImage?
    let rawSchedule: [String: Any]?
}
