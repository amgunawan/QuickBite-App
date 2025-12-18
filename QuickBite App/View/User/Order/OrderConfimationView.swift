//
//  OrderConfirmationView.swift
//  QuickBite
//
//  Created by student on 19/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct OrderConfirmationView: View {
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var navState: AppNavigationState
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    @State private var showingTimeSheet = false
    
    // State Status Toko (Open/Closed)
    @State private var storeStatusText: String = "Loading..."
    @State private var isStoreClosed: Bool = false
    @State private var closingTime: String = "22:00"
    
    @State private var totalDiscountAmount: Int = 0
    
    // Default selection
    @State private var selectedTime: TimeSlot? = nil
    
    @State private var navigateToCompleted = false
    @State private var generatedQR: UIImage?
    @State private var generatedOrderId: String = ""
    @State private var isPlacingOrder: Bool = false
    @StateObject private var vm = ActivityViewModel()
    
    // MARK: - Group Order Data
    var billingOption: BillingOption = .individual
    var groupMembers: [UserMember] = []
    var isGroupOrder: Bool = false
    var groupName: String = ""
    
    // MARK: - Computed Properties for Display
    
    var originalSubtotal: Double {
        return cart.totalPrice + Double(totalDiscountAmount)
    }
    
    var groupItemsSubtotal: Double {
        let friendsTotal = groupMembers.filter { !$0.isCurrentUser }.reduce(0.0) { sum, member in
            sum + member.items.reduce(0.0) { $0 + ($1.currentPrice * Double($1.quantity)) }
        }
        return cart.totalPrice + friendsTotal
    }
    
    var amountToPay: Double {
        if !isGroupOrder { return cart.totalPrice + 2500 }
        
        switch billingOption {
        case .individual:
            return cart.totalPrice + 2500
        case .splitEvenly:
            let totalWithFee = groupItemsSubtotal + 2500
            let memberCount = max(1, groupMembers.count)
            return totalWithFee / Double(memberCount)
        case .full:
            return groupItemsSubtotal + 2500
        }
    }
    
    var originalGrandTotal: Double {
        return originalSubtotal + 2500
    }
    
    private func getUserId() -> String? {
        authVM.currentUserSession?.uid
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. Info Toko
                    storeInfoHeader
                    
                    Rectangle().fill(Color.orange.opacity(0.3)).frame(height: 8)
                    
                    // 2. Pick Up Time Section
                    pickupTimeSection
                    
                    Rectangle().fill(Color.orange.opacity(0.3)).frame(height: 8)
                    
                    // 3. Order List
                    VStack(alignment: .leading, spacing: 16) {
                        Text(isGroupOrder && billingOption == .full ? "Group Order Summary" : "My Order")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        ForEach(cart.items) { item in
                            OrderConfirmationItemRow(item: item)
                        }
                        
                        if isGroupOrder && billingOption == .full {
                            ForEach(groupMembers.filter { !$0.isCurrentUser }) { member in
                                ForEach(member.items) { item in
                                    OrderConfirmationItemRow(item: item)
                                        .opacity(0.7)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    additionalNotesAndUpsell
                    
                    Rectangle().fill(Color.orange.opacity(0.3)).frame(height: 8)
                    
                    // 5. Payment Summary
                    paymentSummarySection
                }
            }
            
            // 6. Bottom Bar (Buy Now)
            bottomBar
        }
        .navigationTitle("Order Confirmation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingTimeSheet) {
            PickUpTimeView(selectedTime: $selectedTime, storeClosingTime: closingTime)
                .environmentObject(calendarManager)
        }
        .navigationDestination(isPresented: $navigateToCompleted) {
            OrderPickUpView(qrImage: generatedQR, orderId: generatedOrderId)
                .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            print("--- OrderConfirmationView Loaded ---")
            print("Is Group Order: \(isGroupOrder)")
            print("Billing Mode: \(billingOption.rawValue)")
            print("Amount to Pay calculated: \(amountToPay)")
            
            fetchStoreSchedule()
            fetchDiscounts()
        }
    }
    
    // MARK: - Sub-UI Components
    
    private var storeInfoHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "storefront")
                .font(.system(size: 24))
                .foregroundColor(.orange)
                .frame(width: 40, height: 40)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 1.5))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Pickup At").font(.caption).foregroundColor(.gray)
                Text(cart.restaurantName.isEmpty ? "Unknown Restaurant" : cart.restaurantName).font(.headline)
                Text(storeStatusText).font(.caption).foregroundColor(isStoreClosed ? .red : .gray)
                HStack(spacing: 4) {
                    Text("Estimated Ready in:").font(.system(size: 13))
                    Text("\(cart.averagePrepTime) minutes").font(.system(size: 13, weight: .bold)).foregroundColor(.orange)
                }.padding(.top, 2)
            }
            Spacer()
        }.padding()
    }
    
    private var pickupTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pick Up Time").font(.system(size: 14, weight: .bold))
                Spacer()
                Button("Pick another time...") { showingTimeSheet = true }.font(.system(size: 13)).foregroundColor(.orange)
            }
            
            Button(action: { showingTimeSheet = true }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedTime?.timeRange ?? "Select Time").font(.system(size: 15, weight: .bold)).foregroundColor(.orange)
                        if let status = selectedTime?.status {
                            Text(status).font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedTime?.isRecommended == true ? .green : .gray)
                        }
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.orange).font(.title2)
                }
                .padding().background(Color.orange.opacity(0.1)).cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 1))
            }.buttonStyle(.plain)
        }.padding()
    }
    
    private var additionalNotesAndUpsell: some View {
        VStack(spacing: 0) {
            VStack {
                Divider()
                HStack {
                    Text("Additional Note:").font(.system(size: 12, weight: .medium))
                    Spacer()
                    TextField("Leave a message...", text: .constant("")).font(.system(size: 12))
                }.padding(.horizontal)
                Divider()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Craving another QuickBite?").font(.system(size: 15, weight: .bold))
                        Text("Go ahead — there's still time to grab one more meal!").font(.system(size: 11)).foregroundColor(.gray)
                    }
                    Spacer()
                    Button("Add More") { dismiss() }
                        .font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.orange).cornerRadius(20)
                }
            }.padding()
        }
    }
    
    private var paymentSummarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment Summary").font(.system(size: 14)).foregroundColor(.gray).padding(.bottom, 4)
            
            SummaryRow(title: "Quantity", value: "\(cart.totalItemCount)")
            
            if isGroupOrder && billingOption == .splitEvenly {
                SummaryRow(title: "Group Subtotal", value: "Rp\(formatPrice(groupItemsSubtotal))")
                SummaryRow(title: "Service fee", value: "Rp2.500")
                SummaryRow(title: "Split share (\(groupMembers.count) people)", value: "Rp\(formatPrice(amountToPay))")
            } else {
                let subtotal = (isGroupOrder && billingOption == .full) ? groupItemsSubtotal : originalSubtotal
                SummaryRow(title: "Subtotal", value: "Rp\(formatPrice(subtotal))")
                
                if totalDiscountAmount > 0 && !(isGroupOrder && billingOption == .full) {
                    SummaryRow(title: "Seller discount", value: "-Rp\(formatPrice(Double(totalDiscountAmount)))", valueColor: .red)
                }
                SummaryRow(title: "Service fee", value: "+Rp2.500")
            }
            
            Divider().padding(.vertical, 4)
            
            HStack {
                Text("Total to Pay").font(.headline)
                Spacer()
                Text("Rp\(formatPrice(amountToPay))")
                    .font(.title3).fontWeight(.bold).foregroundColor(.orange)
            }
        }
        .padding()
        .padding(.bottom, 100)
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    if totalDiscountAmount > 0 && !isGroupOrder {
                        Text("Rp\(formatPrice(originalGrandTotal))").font(.caption).foregroundColor(.gray).strikethrough()
                    }
                    Text("Rp\(formatPrice(amountToPay))").font(.title2).fontWeight(.bold).foregroundColor(.orange)
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Button(action: { placeOrder() }) {
                        Text("Buy Now")
                            .font(.headline).foregroundColor(.white)
                            .padding(.horizontal, 32).padding(.vertical, 12)
                            .background((isStoreClosed || selectedTime == nil) ? Color.gray : Color.orange)
                            .cornerRadius(25)
                    }
                    .disabled(isStoreClosed || selectedTime == nil)
                    
                    if isStoreClosed {
                        Text("Store is currently closed")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                    } else if selectedTime == nil {
                        Text("Select time to continue")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                    }
                }
            }
            .padding()
            .background(Color.white)
        }
    }
    
    // Logic Functions (Same as your code)
    func fetchDiscounts() {
        guard !cart.restaurantId.isEmpty else { return }
        let db = Firestore.firestore()
        let now = Date()
        db.collection("discounts").whereField("end_date_time", isGreaterThan: now).getDocuments { snapshot, error in
            if let error = error { print("Error: \(error)"); return }
            guard let documents = snapshot?.documents else { return }
            var calculatedTotal: Int = 0
            for doc in documents {
                let data = doc.data()
                let docStoreId = (data["store_id"] as? DocumentReference)?.documentID ?? (data["store_id"] as? String ?? "").replacingOccurrences(of: "stores/", with: "")
                if docStoreId == cart.restaurantId {
                    let amount = data["discount_amount"] as? Int ?? 0
                    let itemId = data["item_id"] as? String ?? ""
                    if let cartItem = cart.items.first(where: { $0.menuItemId == itemId }) {
                        calculatedTotal += (amount * cartItem.quantity)
                    }
                }
            }
            DispatchQueue.main.async { self.totalDiscountAmount = calculatedTotal }
        }
    }
    
    func fetchStoreSchedule() {
        guard !cart.restaurantId.isEmpty else { return }
        Firestore.firestore().collection("stores").document(cart.restaurantId).getDocument { snapshot, _ in
            if let data = snapshot?.data(), let schedule = data["store_schedule"] as? [String: Any] {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"; formatter.locale = Locale(identifier: "en_US")
                let today = formatter.string(from: Date())
                if let todaySched = schedule[today] as? [String: Any], let open = todaySched["open_time"] as? String, let close = todaySched["close_time"] as? String {
                    self.closingTime = close
                    checkTimeStatus(open: open, close: close)
                } else {
                    self.storeStatusText = "Closed Today"; self.isStoreClosed = true
                }
            }
        }
    }
    
    func checkTimeStatus(open: String, close: String) {
        let formatter = DateFormatter(); formatter.dateFormat = "HH:mm"
        let current = formatter.string(from: Date())
        if current < open || current > close {
            self.storeStatusText = "Closed"; self.isStoreClosed = true
        } else {
            self.storeStatusText = "Open until \(close)"; self.isStoreClosed = false
        }
    }
    
    func placeOrder() {
        guard let selectedTime, !isStoreClosed, !isPlacingOrder, let userId = authVM.currentUserSession?.uid else { return }
        isPlacingOrder = true
        
        // 1. Get email prefix (everything before @) for personal orders
        let userEmail = authVM.currentUserSession?.email ?? ""
        let emailPrefix = userEmail.components(separatedBy: "@").first ?? "Guest"
        
        // 2. Decide: Use Group Name if it's a group order, otherwise use the Email Prefix
        let finalCustomerName = isGroupOrder ? groupName : emailPrefix
        
        let items = cart.items.map { "\($0.quantity)x \($0.name)" }
        
        print("DEBUG: Placing order for \(finalCustomerName) total Rp\(Int(amountToPay))")
        
        OrderService().createOrder(
            cartItems: cart.items,
            storeId: cart.restaurantId,
            pickupDate: selectedTime.rawDate ?? Date(),
            totalCost: Int(amountToPay),
            userId: userId,
            isGroupOrder: isGroupOrder
        ) { orderId in
            guard let orderId else {
                isPlacingOrder = false
                return
            }

            DispatchQueue.main.async {
                navState.activeOrderId = orderId
                navState.selectedTab = 1
                navState.activitySegment = .inProgress

                cart.clearCart()
                navState.isCartPresented = false
                self.generatedOrderId = orderId
                self.navigateToCompleted = true
                
                print("✅ Order successfully placed: \(orderId)")
            }
        }
    }
}

// MARK: - MISSING SUBVIEWS (ADD THESE BACK)

struct OrderConfirmationItemRow: View {
    let item: CartItemModel
    @State private var displayImageURL: URL? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = displayImageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 60, height: 60).cornerRadius(8).clipped()
            } else {
                Rectangle().fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60).cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.system(size: 15, weight: .semibold))
                Text(item.optionsDescription).font(.system(size: 12)).foregroundColor(.gray).lineLimit(1)
                
                HStack {
                    Text("Rp\(formatPrice(item.currentPrice))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.orange)
                    Spacer()
                    Text("x\(item.quantity)").font(.system(size: 14))
                }
            }
        }
        .onAppear { loadImage() }
    }
    
    func loadImage() {
        let urlString = item.imageName
        if urlString.starts(with: "http") {
            self.displayImageURL = URL(string: urlString)
        } else if urlString.starts(with: "gs://") {
            let storageRef = Storage.storage().reference(forURL: urlString)
            storageRef.downloadURL { url, error in
                if let url = url {
                    DispatchQueue.main.async { self.displayImageURL = url }
                }
            }
        }
    }
}

// MARK: - Previews

struct OrderConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let mockItem = CartItemModel(
            id: UUID(),
            menuItemId: "a",
            name: "Chicken Teriyaki",
            imageName: "",
            basePrice: 42500,
            baseOriginalPrice: 42500,
            prepTime: 15,
            quantity: 1,
            note: "",
            selectedOptions: []
        )
        
        let members = [
            UserMember(
                firestoreId: UUID().uuidString,
                name: "Angela",
                username: "a",
                initial: "A",
                color: .orange,
                isCurrentUser: true,
                status: .ready,
                items: []
            ),
            UserMember(
                firestoreId: UUID().uuidString,
                name: "Heidy",
                username: "h",
                initial: "H",
                color: .blue,
                status: .ready,
                items: [mockItem]
            )
        ]
        
        return Group {
            NavigationStack { OrderConfirmationView(isGroupOrder: false) }
                .previewDisplayName("Personal Order")
            NavigationStack { OrderConfirmationView(billingOption: .splitEvenly, groupMembers: members, isGroupOrder: true) }
                .previewDisplayName("Group: Split Evenly")
            NavigationStack { OrderConfirmationView(billingOption: .full, groupMembers: members, isGroupOrder: true) }
                .previewDisplayName("Group: Leader Pays All")
        }
        .environmentObject(CartViewModel())
        .environmentObject(CalendarManager())
        .environmentObject(AppNavigationState())
        .environmentObject(AuthenticationViewModel())
    }
}
