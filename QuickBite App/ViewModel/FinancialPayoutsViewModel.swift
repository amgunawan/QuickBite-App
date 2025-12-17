//
//  FinancialPayoutsViewModel.swift
//  QuickBite App
//
//  Created by Angela on 15/12/25.
//


import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor
final class FinancialPayoutsViewModel: ObservableObject {

    // MARK: - Published States
    @Published var bankName: String = ""
    @Published var accountHolder: String = ""
    @Published var accountNumber: String = ""
    @Published var nmid: String = ""

    @Published var isLoading: Bool = false
    @Published var isDirty: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let storeId: String

    // MARK: - Init
    init(storeId: String) {
        self.storeId = storeId
    }

    // MARK: - Validation
    var isValid: Bool {
        !bankName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !accountHolder.trimmingCharacters(in: .whitespaces).isEmpty &&
        !accountNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nmid.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Fetch (OPTION A)
    func fetchPayoutDetails() {
        isLoading = true
        errorMessage = nil

        db.collection("stores")
            .document(storeId)
            .getDocument { [weak self] snapshot, error in
                guard let self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard
                        let data = snapshot?.data(),
                        let payout = data["payout_details"] as? [String: Any]
                    else {
                        // This is OK — first-time setup
                        self.isDirty = false
                        return
                    }

                    self.bankName = payout["bank_name"] as? String ?? ""
                    self.accountHolder = payout["account_holder"] as? String ?? ""
                    self.accountNumber = payout["account_number"] as? String ?? ""
                    self.nmid = payout["nmid"] as? String ?? ""
                    self.isDirty = false
                }
            }
    }

    // MARK: - Save (OPTION A)
    func savePayoutDetails(completion: @escaping () -> Void) {
        guard isValid else { return }

        isLoading = true
        errorMessage = nil

        let payload: [String: Any] = [
            "bank_name": bankName,
            "account_holder": accountHolder,
            "account_number": accountNumber,
            "nmid": nmid
        ]

        db.collection("stores")
            .document(storeId)
            .updateData([
                "payout_details": payload
            ]) { [weak self] error in
                guard let self else { return }

                Task { @MainActor in
                    self.isLoading = false

                    if let error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.isDirty = false
                        completion()
                    }
                }
            }
    }

    // MARK: - Helpers
    func markDirty() {
        if !isDirty { isDirty = true }
    }

    func numericAccountOnly(_ value: String) {
        let filtered = value.filter { $0.isNumber }
        if filtered != value {
            accountNumber = filtered
        }
        markDirty()
    }
}
