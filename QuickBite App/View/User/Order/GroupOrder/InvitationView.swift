//
//  InvitationView.swift
//  QuickBite
//
//  Created by student on 15/12/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct InvitationView: View {
    let orderId: String
    var mockData: [String: Any]? = nil
    
    @Environment(\.dismiss) var dismiss
    @Binding var isJoined: Bool
    
    @State private var orderData: [String: Any]?
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // 1. Native Grouped Background
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .controlSize(.large)
            } else if let data = orderData {
                VStack(spacing: 24) {
                    Spacer()
                    
                    // 2. The "Invitation Card"
                    VStack(spacing: 20) {
                        // Avatar Icon
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.wave.2.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 10)
                        
                        VStack(spacing: 8) {
                            Text("Group Order Invite")
                                .font(.subheadline)
                                .textCase(.uppercase)
                                .foregroundColor(.secondary)
                                .fontWeight(.semibold)
                            
                            HStack{
                                Text("\(data["leaderName"] as? String ?? "A friend")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("wants to eat with you!")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        
                        Divider()
                        
                        // Restaurant Details
                        HStack(spacing: 15) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Ordering from:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(data["restaurantName"] as? String ?? "Unknown Restaurant")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 30)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // 3. Action Buttons (Vertical Stack is more native for "Primary vs Secondary")
                    VStack(spacing: 16) {
                        Button(action: {
                            joinGroupOrder()
                        }) {
                            HStack {
                                Text("Join Group Order")
                                    .fontWeight(.medium)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .controlSize(.large)
                        .cornerRadius(24)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("No, thanks")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            } else {
                // Error State
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundColor(.gray)
                    Button("Close") { dismiss() }
                        .buttonStyle(.bordered)
                }
            }
        }
        // 4. Standard Sheet Presentation
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            fetchOrderDetails()
        }
    }
    
    // Logic Functions (Unchanged)
    func fetchOrderDetails() {
        if let mock = mockData {
            self.orderData = mock
            self.isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection("group_orders").document(orderId).getDocument { snapshot, error in
            isLoading = false
            if let data = snapshot?.data(), snapshot?.exists == true {
                self.orderData = data
            } else {
                self.errorMessage = "This order is no longer available."
            }
        }
    }
    
    func joinGroupOrder() {
        if mockData != nil {
            isJoined = true
            dismiss()
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("group_orders").document(orderId).updateData([
            "memberIds": FieldValue.arrayUnion([uid])
        ]) { error in
            if error == nil {
                isJoined = true
                dismiss()
            }
        }
    }
}

// Updated Preview to test the look
struct InvitationView_Previews: PreviewProvider {
    static var previews: some View {
        InvitationView(
            orderId: "dummy",
            mockData: [
                "leaderName": "Angela",
                "restaurantName": "Madam Liy"
            ],
            isJoined: .constant(false)
        )
    }
}
