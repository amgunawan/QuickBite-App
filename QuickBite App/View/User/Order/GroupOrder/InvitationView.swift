//
//  InvitationVview.swift
//  QuickBite
//
//  Created by student on 15/12/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct InvitationView: View {
    let orderId: String
    var mockData: [String: Any]? = nil // For Preview
    
    @Environment(\.dismiss) var dismiss
    
    // 1. Add this Binding to signal "Success"
    @Binding var isJoined: Bool
    
    @State private var orderData: [String: Any]?
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading invitation...")
                    .scaleEffect(1.5)
                    .padding()
            } else if let data = orderData {
                
                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding(.top, 40)
                
                Text("You're Invited!")
                    .font(.largeTitle)
                    .bold()
                
                Text("\(data["leaderName"] as? String ?? "A friend") invites you to join a group order at:")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Text(data["restaurantName"] as? String ?? "Restaurant")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 5)

                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Decline")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // 2. Join Action
                    Button(action: {
                        joinGroupOrder()
                    }) {
                        Text("Join Order")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                
            } else {
                Text(errorMessage).foregroundColor(.gray)
            }
        }
        .padding()
        .onAppear {
            fetchOrderDetails()
        }
    }
    
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
        // Mock success for preview
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
                // 3. Signal success and dismiss
                isJoined = true
                dismiss()
            }
        }
    }
}

struct InvitationView_Previews: PreviewProvider {
    static var previews: some View {
        InvitationView(
            orderId: "dummy",
            mockData: ["leaderName": "Angela", "restaurantName": "Raburi"],
            isJoined: .constant(false) // Add dummy binding
        )
    }
}
