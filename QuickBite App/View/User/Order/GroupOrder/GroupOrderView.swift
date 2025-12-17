//
//  GroupOrderView.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI
import FirebaseFirestore

struct GroupOrderView: View {
    @Environment(\.dismiss) var dismiss
    
    let restaurantName: String
    
    @State private var isEditingGroupName: Bool = false
    @FocusState private var isGroupNameFocused: Bool
    
    @Binding var selectedBillingOption: BillingOption 
    @State private var showBillingSheet = false
    
    @State private var orderDeadline: Date?
    @State private var showDeadlineSheet = false
    
    @Binding var isGroupOrderActive: Bool
    @Binding var groupName: String
    @Binding var groupMembers: [UserMember]
    
    var leader: UserMember? {
        groupMembers.first(where: { $0.isCurrentUser })
    }
    
    @State private var showInviteAlert = false
    @State private var inviteMessage = ""
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            ZStack(alignment: .top) {
                ZStack {
                    Color(red: 1.0, green: 0.92, blue: 0.84)
                        .frame(height: 200)
                    
                    Image("GroupOrderHeader")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.orange.opacity(0.3))
                }
                .padding(.top, 15)
                
                // --- Kartu Konten Utama ---
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Info Group Leader
                    HStack(spacing: 16) {
                        // Avatar Besar (Dynamic based on Leader)
                        Text(leader?.initial ?? "?") // Show Leader Initial
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(leader?.isCurrentUser == true ? Color(red: 0.9, green: 0.4, blue: 0.1) : .white)
                            .frame(width: 70, height: 70)
                        // Use Leader's color
                            .background(leader?.isCurrentUser == true ? Color.orange.opacity(0.2) : (leader?.color.opacity(0.8) ?? .gray))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            
                            HStack{
                                if isEditingGroupName {
                                    TextField("Group Name", text: $groupName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .focused($isGroupNameFocused)
                                        .onSubmit {
                                            isEditingGroupName = false
                                        }
                                } else {
                                    // Display Group Name
                                    Text(groupName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if isEditingGroupName {
                                        isEditingGroupName = false
                                    } else {
                                        isEditingGroupName = true
                                        isGroupNameFocused = true
                                    }
                                }) {
                                    Image(systemName: isEditingGroupName ? "checkmark.circle.fill" : "pencil")
                                        .font(.system(size: 25))
                                        .foregroundColor(isEditingGroupName ? .green : .gray)
                                }
                                
                            }
                            Text("You are the **Leader**")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                    }
                    
                    // 2. Baris Pengaturan (Billing & Deadline)
                    VStack(spacing: 16) {
                        Button(action: {
                            showBillingSheet = true
                        }) {
                            GroupOrderSettingRow(
                                icon: "creditcard",
                                iconColor: .orange,
                                title: "Billing",
                                subtitle: selectedBillingOption.rawValue // Subtitle dinamis
                            )
                        }
                        .buttonStyle(.plain)
                        
//                         deadline
                        // Order Deadline Section
                        Button(action: {
                            // Action is now disabled
                            showDeadlineSheet = true
                        }) {
                            GroupOrderSettingRow(
                                icon: "clock",
                                iconColor: .gray, // Changed to gray to indicate disabled state
                                title: "Order Deadline",
                                // Updated subtitle with the "Future Feature" description
                                subtitle: "Coming Soon: Set a time limit for members to join."
                            )
                            .opacity(0.6) // Makes the whole row look dimmed/disabled
                        }
                        .buttonStyle(.plain)
                        .disabled(true) // ✅ Disables the button interaction
                    }
                    
                    Spacer()
                    // 3. Bagian "Who's in?"
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Who's in? (\(groupMembers.count))")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                
                                // Loop menampilkan anggota
                                ForEach(groupMembers) { member in
                                    Text(member.initial)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(member.isCurrentUser ? Color(red: 0.9, green: 0.4, blue: 0.1) : .white)
                                        .frame(width: 50, height: 50)
                                        .background(member.isCurrentUser ? Color.orange.opacity(0.2) : member.color.opacity(0.8))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(member.isCurrentUser ? Color(red: 0.9, green: 0.4, blue: 0.1) : Color.clear, lineWidth: 1)
                                        )
                                }
                                
                                // DIPERBARUI: Tombol Tambah sekarang NavigationLink (Push Page)
                                NavigationLink(destination: CreateGroupOrderView(members: $groupMembers)) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(.orange)
                                        .frame(width: 50, height: 50)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                                .foregroundColor(.orange)
                                        )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                }
                .padding(24)
                .background(Color.white)
                .clipShape(TopRoundedCorner(radius: 30))
                .padding(.top, 170)
            }
            
            Divider()
                .padding(.bottom, 5)
            
            //tombol create
            VStack {
                Button(action: {
                    if isGroupOrderActive {
                        print("Group order deleted")
                        isGroupOrderActive = false
                        if let currentUser = groupMembers.first(where: { $0.isCurrentUser }) {
                            groupMembers = [currentUser]
                        }
                        dismiss()
                    } else {
                        
                        print("Group order created: \(groupName)")
                        isGroupOrderActive = true
                        dismiss()
                    }
                }) {
                    Text(isGroupOrderActive ? "Delete Group Order" : "Create Group Order")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            isGroupOrderActive ? Color.red : (groupMembers.count > 1 ? Color.orange : Color(.systemGray5))
                        )
                        .cornerRadius(30)
                }
                .disabled(!isGroupOrderActive && groupMembers.count <= 1)
                
                
            }
            .padding()
            .background(Color.white)
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("Group Order").font(.headline).foregroundColor(.black)
                    Text(restaurantName).font(.caption).foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showBillingSheet) {
            BillingOptionSheet(selectedOption: $selectedBillingOption)
        }
        .sheet(isPresented: $showDeadlineSheet) {
            OrderDeadlineSheet(initialDate: orderDeadline, onSave: { date in self.orderDeadline = date })
        }
        .onAppear {
            if groupName.isEmpty || groupName == "Group Order" {
                if let leader = leader {
                    let firstName = leader.name.split(separator: " ").first ?? "My"
                    groupName = "\(firstName)'s Group"
                }
            }
        }
        .alert("Invitations Sent!", isPresented: $showInviteAlert) {
            Button("OK") {
                isGroupOrderActive = true
                dismiss()
            }
        } message: {
            Text(inviteMessage)
        }
    }
    
    func handleGroupOrderAction() {
            if isGroupOrderActive {
                // Logic Delete Order
                print("Group order deleted")
                isGroupOrderActive = false
                // Reset to just the current user
                if let currentUser = groupMembers.first(where: { $0.isCurrentUser }) {
                    groupMembers = [currentUser]
                }
                dismiss()
            } else {
                // Logic Create Order & Send Invites
                createGroupOrderInFirestore()
            }
    }
    
    func createGroupOrderInFirestore() {
        guard let leader = leader else { return }
        
        for index in groupMembers.indices {
            if !groupMembers[index].isCurrentUser {
                // Assuming your UserMember struct has a property called 'status'
                groupMembers[index].status = .invited
            }
        }
        
        let db = Firestore.firestore()
        
        // 1. Prepare Data for the "Lobby"
        let memberIds = groupMembers.map { $0.id }
        

        let orderData: [String: Any] = [
            "restaurantName": restaurantName,
            "leaderName": leader.name,
            "leaderId": leader.id,
            "groupName": groupName,
            "memberIds": memberIds,
            "invitedIds": memberIds.filter { $0 != leader.id }, // Explicitly track who needs an invite
            "createdAt": FieldValue.serverTimestamp(),
            "status": "open", // Open for joining
            "deadline": orderDeadline ?? Date().addingTimeInterval(3600)
        ]
        
        // 2. Create the document
        // This creation triggers the Cloud Function to send Push Notifications
        db.collection("group_orders").addDocument(data: orderData) { error in
            if let error = error {
                print("Error creating group lobby: \(error)")
                inviteMessage = "Failed to create group. Please try again."
                showInviteAlert = true
            } else {
                // 3. Success
                let count = groupMembers.count - 1
                inviteMessage = "Group created! We've sent invites to \(count) friends to join you."
                showInviteAlert = true
            }
        }
    }
}


// MARK: - Subview: Baris Pengaturan
struct GroupOrderSettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        // Bayangan halus
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        // Border tipis abu-abu
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray6), lineWidth: 1)
        )
    }
}

// MARK: - Custom Shape: Sudut Atas Melengkung
struct TopRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = [.topLeft, .topRight]
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct GroupOrderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GroupOrderView(
                restaurantName: "Raburi",
                selectedBillingOption: .constant(.individual),
                isGroupOrderActive: .constant(false),
                groupName: .constant("Angela's Group"),
                groupMembers: .constant([
                    UserMember(name: "Angela", username: "@angela", initial: "A", color: .orange, isCurrentUser: true)
                ])
            )
        }
    }
}
