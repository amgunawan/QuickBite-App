//
//  TenantHeaderViewModel.swift
//  QuickBite
//
//  Created by student on 09/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import Combine

class TenantHeaderViewModel: ObservableObject {
    @Published var tenantName: String = ""
    @Published var searchImageURL: URL? = nil
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func loadTenantHeader(storeId: String) {
        db.collection("stores")
            .document(storeId)
            .getDocument { snapshot, error in
                
                if let error = error {
                    print("❌ Failed to load tenant header:", error.localizedDescription)
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                
                // Tenant Name
                let name = data["name"] as? String ?? ""
                DispatchQueue.main.async {
                    self.tenantName = name
                }
                
                // Search Image (gs://)
                if let gsURL = data["search_url"] as? String {
                    self.loadStorageImage(gsURL)
                }
            }
    }
    
    private func loadStorageImage(_ gsURL: String) {
        let path = gsURL.replacingOccurrences(of: "gs://quickbite-app-fb529.firebasestorage.app/", with: "")
        
        let ref = storage.reference(withPath: path)
        
        ref.downloadURL { url, error in
            if let error = error {
                print("❌ Failed to load image URL:", error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.searchImageURL = url
            }
        }
    }
}

