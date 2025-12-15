//
//  FinancialPayoutsViewModel.swift
//  QuickBite App
//
//  Created by Angela on 15/12/25.
//


import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

final class FinancialPayoutsViewModel: ObservableObject {

    // MARK: - Published States (bind ke View)
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

    // MARK: - Fetch
    func fetchPayoutDetails() {
        isLoading = true
        errorMessage = nil

        db.collection("stores")
            .document(storeId)
            .getDocument { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard
                    let data = snapshot?.data(),
                    let payout = data["payout_details"] as? [String: Any]
                else {
                    self.errorMessage = "Payout details not found"
                    return
                }

                self.bankName = payout["bank_name"] as? String ?? ""
                self.accountHolder = payout["account_holder"] as? String ?? ""
                self.accountNumber = payout["account_number"] as? String ?? ""
                self.nmid = payout["nmid"] as? String ?? ""

                // Data awal dari server → belum diedit
                self.isDirty = false
            }
    }

    // MARK: - Save
    func savePayoutDetails(completion: @escaping () -> Void) {
        guard isValid else { return }

        isLoading = true
        errorMessage = nil

        db.collection("stores")
            .document(storeId)
            .updateData([
                "payout_details.bank_name": bankName,
                "payout_details.account_holder": accountHolder,
                "payout_details.account_number": accountNumber,
                "payout_details.nmid": nmid
            ]) { [weak self] error in
                guard let self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isDirty = false
                    completion()
                }
            }
    }

    // MARK: - Helper (dipanggil dari View)
    func markDirty() {
        isDirty = true
    }

    func numericAccountOnly(_ value: String) {
        accountNumber = value.filter { $0.isNumber }
        isDirty = true
    }
}
