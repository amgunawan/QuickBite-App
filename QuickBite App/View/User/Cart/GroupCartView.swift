//
//  GroupCartView.swift
//  QuickBite
//
//  Created by student on 27/11/25.
//

import SwiftUI
import FirebaseFirestore

struct GroupCartView: View {
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    @Binding var groupMembers: [UserMember]
    
    @State private var showOrderConfirmation = false
    @State private var showRemoveAlert = false
    @State private var memberToRemove: UserMember?
    
    var groupOrderId: String?
    @Binding var groupName: String
    @State private var itemToEdit: CartItemModel?
    
    @Binding var selectedBillingOption: BillingOption
    
    var groupTotal: Double {
        let myTotal = cart.totalPrice
        
        let friendsTotal = groupMembers.reduce(0.0) { sum, member in
            let memberItemsSum = member.items.reduce(0.0) { itemSum, item in
                itemSum + (item.currentPrice * Double(item.quantity))
            }
            return sum + memberItemsSum
        }
        
        return myTotal + friendsTotal
    }
    
    var isEveryoneReady: Bool {
        // Everyone else is ready AND my cart isn't empty
        let friendsReady = groupMembers.filter { !$0.isCurrentUser }.allSatisfy { $0.status == .ready }
        let iAmReady = !cart.items.isEmpty
        return friendsReady && iAmReady
    }
    
    private var pendingMembersNames: String {
        groupMembers.filter { $0.status != .ready }.map { $0.name }.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 24) {
                        currentUserSection
                        otherMembersSection
                    }
                    .padding(.top)
                    .padding(.bottom, 120)
                }
                
                bottomBar
            }
            .navigationTitle(groupName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .alert("Remove Member?", isPresented: $showRemoveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    if let member = memberToRemove {
                        removeMember(member)
                    }
                }
            } message: {
                Text("Are you sure you want to remove \(memberToRemove?.name ?? "this member")?")
            }
            .sheet(item: $itemToEdit) { cartItem in
                MenuOptionsView(
                    restaurantName: cart.restaurantName,
                    restaurantId: cart.restaurantId,
                    item: convertToMenuItem(cartItem),
                    finalPrice: cartItem.basePrice,
                    originalPrice: cartItem.baseOriginalPrice,
                    itemToEdit: cartItem
                )
                .environmentObject(cart)
            }
        }
        .onChange(of: selectedBillingOption) { newValue in
            print("DEBUG: Billing changed in GroupCartView to: \(newValue.rawValue)")
        }
    }
    
    // MARK: - Subviews (Helps Compiler Speed)
    
    private var currentUserSection: some View {
        let currentUser = groupMembers.first(where: { $0.isCurrentUser })
        let name = currentUser?.name ?? "User"
        
        // Logic: If cart is empty, user is still "Ordering" (Adding Items)
        let currentUserStatus: MemberStatus = cart.items.isEmpty ? .ordering : .ready
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                UserAvatar(initial: currentUser?.initial ?? "U", color: .orange, isCurrentUser: true)
                VStack(alignment: .leading) {
                    Text("\(name) (You)").font(.headline)
                    // Use the dynamic status here
                    statusBadge(for: currentUserStatus)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Rp\(formatPrice(cart.totalPrice))")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text("\(cart.totalItemCount) menu").font(.caption).foregroundColor(.gray)
                }
            }
            
            if cart.items.isEmpty {

                Text("Your cart is empty. Add some items!")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6).opacity(0.3))
                    .cornerRadius(12)
            } else {
                ForEach(cart.items) { item in
                    GroupCartItemRow(item: item) { itemToEdit = item }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }
    
//    private var otherMembersSection: some View {
//        ForEach(groupMembers.filter { !$0.isCurrentUser }) { member in
//            VStack(alignment: .leading, spacing: 12) {
//                HStack {
//                    UserAvatar(initial: member.initial, color: member.color)
//                    VStack(alignment: .leading) {
//                        Text(member.name).font(.headline)
//                        statusBadge(for: member.status)
//                    }
//                    Spacer()
//                    
//                    if member.status != .invited {
//                        memberPriceInfo(member)
//                    } else {
//                        Button("Remove") {
//                            memberToRemove = member
//                            showRemoveAlert = true
//                        }.font(.caption).foregroundColor(.red)
//                    }
//                }
//                
//                memberContent(member)
//            }
//            .padding(.horizontal)
//        }
//    }
    
    private var otherMembersSection: some View {
        // We use indices to allow direct modification of the @Binding array
        ForEach(groupMembers.indices, id: \.self) { index in
            let member = groupMembers[index]
            
            // Skip the current user (Leader is handled in currentUserSection)
            if !member.isCurrentUser {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        UserAvatar(initial: member.initial, color: member.color)
                        VStack(alignment: .leading) {
                            Text(member.name).font(.headline)
                            statusBadge(for: member.status)
                        }
                        
                        Spacer()
                        
                        // --- TRIAL BUTTON FOR TESTING ---
                        // Show this button if they are still "Invited" or "Ordering"
                        if member.status != .ready {
                            Button("Test: Set Ready") {
                                // This updates the Binding array locally for your trial
                                groupMembers[index].status = .ready
                            }
                            .font(.system(size: 10, weight: .bold))
                            .padding(6)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                        }
                        // --------------------------------
                        
                        // Price and Remove logic
                        if member.status != .invited {
                            memberPriceInfo(member)
                        } else {
                            Button("Remove") {
                                memberToRemove = member
                                showRemoveAlert = true
                            }.font(.caption).foregroundColor(.red)
                        }
                    }
                    
                    memberContent(member)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func memberPriceInfo(_ member: UserMember) -> some View {
        let total = member.items.reduce(0.0) { $0 + ($1.currentPrice * Double($1.quantity)) }
        let count = member.items.reduce(0) { $0 + $1.quantity }
        return VStack(alignment: .trailing) {
            Text("Rp\(formatPrice(total))").font(.headline).foregroundColor(.orange)
            Text("\(count) menu").font(.caption).foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private func memberContent(_ member: UserMember) -> some View {
        if member.status == .invited {
            HStack {
                Text("Waiting to join...").font(.subheadline).italic().foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).stroke(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundColor(.gray.opacity(0.5)))
        } else if member.items.isEmpty {
            Text("\(member.name) is looking at the menu...").font(.subheadline).italic().foregroundColor(.gray)
                .padding().frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6).opacity(0.3)).cornerRadius(12)
        } else {
            ForEach(member.items) { item in
                GroupCartItemRow(item: item, onChange: {})
                    .padding().background(Color(.systemGray6).opacity(0.5)).cornerRadius(12)
            }
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                basketIcon
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Rp\(formatPrice(cart.totalPrice))").font(.headline).foregroundColor(.orange)
                    Text("(Total: Rp\(formatPrice(groupTotal)))").font(.headline).foregroundColor(.orange)
                }
                
                // CHECKOUT LOGIC
                NavigationLink(destination: OrderConfirmationView(
                    billingOption: selectedBillingOption, // Dynamic binding value
                    groupMembers: groupMembers,
                    isGroupOrder: true
                ).environmentObject(cart)) {
                    Text("Checkout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(isEveryoneReady ? Color.orange : Color.gray)
                        .cornerRadius(25)
                        .onAppear {
                            // DEBUGGING PRINTS
                            print("--- GroupCartView Debug ---")
                            print("Selected Billing Option: \(selectedBillingOption.rawValue)")
                            print("Member Count: \(groupMembers.count)")
                            print("Is Everyone Ready: \(isEveryoneReady)")
                        }
                }
                .disabled(!isEveryoneReady)
                .id(selectedBillingOption)
            }
            .padding()
            .background(Color.white)
            
            if !isEveryoneReady {
                Text("Waiting for: \(pendingMembersNames)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var basketIcon: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "basket").font(.system(size: 24)).foregroundColor(.orange)
            let totalItems = cart.totalItemCount + 1 // dummy
            if totalItems > 0 {
                Text("\(totalItems)").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                    .frame(width: 16, height: 16).background(Color.orange).clipShape(Circle()).offset(x: 6, y: -6)
            }
        }
    }

    @ViewBuilder
    private func statusBadge(for status: MemberStatus) -> some View {
        HStack(spacing: 4) {
            if status == .ready {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                Text("Ready").foregroundColor(.green)
            } else if status == .invited {
                Text("Invited...").foregroundColor(.orange)
            } else {
                Text("Adding Items...").foregroundColor(.blue)
            }
        }
        .font(.caption)
        .padding(.horizontal, 6).padding(.vertical, 2)
        .background(status == .ready ? Color.green.opacity(0.1) : (status == .invited ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1)))
        .cornerRadius(4)
    }

    // MARK: - Logic Functions
    
    func removeMemberFromFirestore(memberId: String) {
        guard let orderId = groupOrderId else { return }
        Firestore.firestore().collection("group_orders").document(orderId).updateData([
            "memberIds": FieldValue.arrayRemove([memberId]),
            "invitedIds": FieldValue.arrayRemove([memberId])
        ])
    }
    
    func removeMember(_ member: UserMember) {
        if let index = groupMembers.firstIndex(where: { $0.id == member.id }) {
            groupMembers.remove(at: index)
            removeMemberFromFirestore(memberId: member.id)
        }
    }
    
    func convertToMenuItem(_ cartItem: CartItemModel) -> MenuItem {
        return MenuItem(itemId: cartItem.menuItemId, name: cartItem.name, description: nil, price: Int(cartItem.basePrice), category: nil, imageURL: cartItem.imageName, defaultStock: nil, prepTimeMinutes: cartItem.prepTime, options: nil)
    }
}

// Component: User Avatar
struct UserAvatar: View {
    let initial: String
    let color: Color
    var isCurrentUser: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(initial)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isCurrentUser ? Color(red: 0.9, green: 0.4, blue: 0.1) : .white)
                .frame(width: 50, height: 50)
                .background(isCurrentUser ? Color.orange.opacity(0.2) : color.opacity(0.8))
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(isCurrentUser ? Color.orange : Color.clear, lineWidth: 1)
                )
            
            if isCurrentUser {
                Image(systemName: "asterisk")
                    .font(.system(size: 8))
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .background(Color.red)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    .offset(x: 0, y: 0)
            }
        }
    }
}

// Component: Item Row for Group Cart
struct GroupCartItemRow: View {
    let item: CartItemModel
    // 1. Add this closure property
    let onChange: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image Logic (Same as before)
            if let url = URL(string: item.imageName), item.imageName.starts(with: "http") {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .clipped()
            } else {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    
                    // 2. Call onChange inside the button
                    Button("Change") {
                        onChange()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                Text(item.optionsDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack {
                    Text("Rp\(formatPrice(item.currentPrice))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                    if item.baseOriginalPrice != nil {
                        Text("Rp\(formatPrice(item.originalPrice))")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                    Spacer()
                    
                    // Static Stepper for display
                    HStack(spacing: 8) {
                        Image(systemName: "minus.square")
                            .foregroundColor(.gray)
                        Text("\(item.quantity)")
                            .font(.subheadline)
                        Image(systemName: "plus.square.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

struct GroupCartView_Previews: PreviewProvider {
    static var previews: some View {
        // Create dummy data
        let dummyMembers = [
            UserMember(name: "Angela", username: "@angela", initial: "A", color: .orange, isCurrentUser: true),
            UserMember(name: "Heidy", username: "@heidy", initial: "H", color: .blue, isCurrentUser: false),
            UserMember(name: "John", username: "@john", initial: "J", color: .red, isCurrentUser: false)
        ]
        
        GroupCartView(
            groupMembers: .constant(dummyMembers),
            groupName: .constant("Angela's Group"),
            selectedBillingOption: .constant(.individual)
        )
            .environmentObject(CartViewModel())
    }
}
