//
//  CreateGroupOrderViewModel.swift
//  QuickBite
//
//  Created by Sharon on 15/12/25.
//

import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class CreateGroupOrderViewModel: ObservableObject {
    @Published var suggestions: [UserMember] = []
    private var db = Firestore.firestore()
    private var allUsers: [UserMember] = []

    func fetchAllUsers() {
        // CHANGE HERE: Added .whereField to filter by role
        db.collection("users")
            .whereField("role", isEqualTo: "customer") // <--- This line does the magic
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.allUsers = documents.compactMap { doc -> UserMember? in
                    do {
                        let appUser = try doc.data(as: AppUser.self)
                        
                        // Optional: Double check here, though the query handles it
                        guard appUser.role == .customer else { return nil }
                        
                        let displayName = appUser.full_name ?? appUser.username
                        let initial = String(displayName.prefix(1)).uppercased()
                        let color = self?.getColor(for: appUser.username) ?? .gray
                        
                        return UserMember(
                            firestoreId: appUser.id ?? UUID().uuidString,
                            name: displayName,
                            username: "@\(appUser.username)",
                            initial: initial,
                            color: color
                        )
                    } catch {
                        print("Error decoding user: \(error)")
                        return nil
                    }
                }
                
                self?.suggestions = self?.allUsers ?? []
            }
    }
    
    // Helper function for colors (keep this same as before)
    private func getColor(for string: String) -> Color {
        let colors: [Color] = [.blue, .green, .pink, .purple, .teal, .yellow, .brown, .orange, .indigo]
        let hash = abs(string.hashValue)
        return colors[hash % colors.count]
    }
}
