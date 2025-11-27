//
//  CuisineTypeViewModel.swift
//  QuickBite
//
//  Created by Angela on 27/11/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

class CuisineTypeViewModel: ObservableObject {
    @Published var cuisineTypes: [String] = []
    
    private var db = Firestore.firestore()
    
    func fetchCuisineTypes() {
        db.collection("cuisine_type")
            .document("XJEBQeWlz0iyy2xf0dng")
            .getDocument { document, error in
                
                if let error = error {
                    print("Error fetching cuisine types: \(error)")
                    return
                }
                
                if let data = document?.data(),
                   let types = data["cuisine_type"] as? [String] {
                    DispatchQueue.main.async {
                        self.cuisineTypes = types
                    }
                }
            }
    }
}
