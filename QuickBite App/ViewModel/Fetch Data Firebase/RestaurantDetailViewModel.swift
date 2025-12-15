//
//  RestaurantDetailViewModel.swift
//  QuickBite
//
//  Created by student on 04/12/25.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Combine

@MainActor
class RestaurantDetailViewModel: ObservableObject {

    // MARK: - STATE
    @Published var menuItems: [MenuItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var discounts: [DiscountModel] = []

    // MARK: - Firebase
    private let storage = Storage.storage()
    private let db = Firestore.firestore()

    // -----------------------------------------------------
    // MARK: - FETCH MENU
    // -----------------------------------------------------

    func fetchMenu(from gsURL: String?) {
        guard let gsURL, !gsURL.isEmpty else {
            errorMessage = "Link menu kosong."
            return
        }

        isLoading = true
        errorMessage = nil

        let storageRef = storage.reference(forURL: gsURL)

        storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
            guard let self else { return }

            if let error {
                self.isLoading = false
                self.errorMessage = "Gagal download: \(error.localizedDescription)"
                return
            }

            guard let data else {
                self.isLoading = false
                self.errorMessage = "Data menu kosong."
                return
            }

            do {
                let decodedItems = try JSONDecoder().decode([MenuItem].self, from: data)

                // 🔐 No ID rewriting — itemId is the source of truth
                self.menuItems = decodedItems

                self.convertMenuImages()

            } catch {
                print("❌ Error Decoding Menu JSON:", error)
                self.isLoading = false
                self.errorMessage = "Format data menu salah."
            }
        }
    }

    // -----------------------------------------------------
    // MARK: - IMAGE URL CONVERSION (gs:// → https://)
    // -----------------------------------------------------

    private func convertMenuImages() {
        let group = DispatchGroup()

        for index in menuItems.indices {
            guard
                let gsLink = menuItems[index].imageURL,
                gsLink.starts(with: "gs://")
            else { continue }

            group.enter()

            let imageRef = storage.reference(forURL: gsLink)
            imageRef.downloadURL { [weak self] url, _ in
                defer { group.leave() }
                guard let self, let httpsURL = url else { return }

                self.menuItems[index].imageURL = httpsURL.absoluteString
            }
        }

        group.notify(queue: .main) {
            self.isLoading = false
        }
    }

    // -----------------------------------------------------
    // MARK: - FETCH DISCOUNTS
    // -----------------------------------------------------

    func fetchDiscounts(storeID: String) {
        let storePath = "/stores/\(storeID)"

        db.collection("discounts")
            .whereField("store_id", isEqualTo: storePath)
            .getDocuments { [weak self] snapshot, _ in
                guard let self else { return }

                self.discounts = snapshot?.documents
                    .compactMap { try? $0.data(as: DiscountModel.self) } ?? []

                print("✅ Berhasil ambil \(self.discounts.count) diskon")
            }
    }

    // -----------------------------------------------------
    // MARK: - PRICE CALCULATION
    // -----------------------------------------------------

    func getPriceInfo(for item: MenuItem) -> (finalPrice: Double, originalPrice: Double?) {

        let basePrice = Double(item.price)

        if let activeDiscount = discounts.first(
            where: { $0.itemId == item.itemId && $0.isActive }
        ) {
            let discountAmount = Double(activeDiscount.amount)
            let finalPrice = max(0, basePrice - discountAmount)
            return (finalPrice, basePrice)
        }

        return (basePrice, nil)
    }
}

// -----------------------------------------------------
// MARK: - MENU SECTION (UI GROUPING)
// -----------------------------------------------------

struct MenuSection: Identifiable {
    var id: String { category }
    let category: String
    let items: [MenuItem]
}

// -----------------------------------------------------
// MARK: - GROUPED MENU
// -----------------------------------------------------

extension RestaurantDetailViewModel {

    var groupedMenu: [MenuSection] {
        let grouped = Dictionary(
            grouping: menuItems,
            by: { $0.category ?? "Other" }
        )

        return grouped
            .sorted { $0.key < $1.key }
            .map { key, value in
                MenuSection(category: key, items: value)
            }
    }
}
