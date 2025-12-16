//
//  TenantSession.swift
//  QuickBite App
//
//  Created by jessica tedja on 15/12/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine 

class TenantSession: ObservableObject {

    @Published var tenantId: String = ""
    @Published var isLoaded: Bool = false

    func loadTenant() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Tenant not logged in")
            return
        }

        let db = Firestore.firestore()

        db.collection("stores")
            .whereField("owner_id", isEqualTo: uid)
            .limit(to: 1)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("🔥 Load tenant error:", error.localizedDescription)
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("❌ No store found for this owner")
                    return
                }

                DispatchQueue.main.async {
                    self.tenantId = document.documentID
                    self.isLoaded = true
                    print("✅ Tenant session loaded:", self.tenantId)
                }
            }
    }
}
