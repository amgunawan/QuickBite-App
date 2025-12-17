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
    
    private let userId = "rOQ7BMWNK9fr7eGypV6lGqFH9Ru1"
    
    // MARK: - Computed Properties for Display
    
    // 1. The Actual Price user pays for items (already inside cart.totalPrice)
    // 2. The Discount Amount (calculated from fetchDiscounts)
    
    // 3. The Original Price (Before Discount)
    var originalSubtotal: Double {
        return cart.totalPrice + Double(totalDiscountAmount)
    }
    
    // 4. Final Amount to Pay (Cart Price + Fee)
    var finalGrandTotal: Double {
        return cart.totalPrice + 2500
    }
    
    // 5. Original Grand Total (for Strikethrough)
    var originalGrandTotal: Double {
        return originalSubtotal + 2500
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. Info Toko
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "storefront")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                            .frame(width: 40, height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 1.5))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pickup At")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            // Nama Restoran
                            Text(cart.restaurantName.isEmpty ? "Unknown Restaurant" : cart.restaurantName)
                                .font(.headline)
                            
                            // Status Toko (Open until...)
                            Text(storeStatusText)
                                .font(.caption)
                                .foregroundColor(isStoreClosed ? .red : .gray)
                            
                            HStack(spacing: 4) {
                                Text("Estimated Ready in:")
                                    .font(.system(size: 13))
                                
                                Text("\(cart.averagePrepTime) minutes")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.top, 2)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Rectangle().fill(Color.orange.opacity(0.3)).frame(height: 8)
                    
                    // 2. Pick Up Time Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Pick Up Time")
                                .font(.system(size: 14, weight: .bold))
                            Spacer()
                            Button("Pick another time...") {
                                showingTimeSheet = true
                            }
                            .font(.system(size: 13))
                            .foregroundColor(.orange)
                        }
                        
                        // Kartu Waktu Terpilih
                        Button(action: { showingTimeSheet = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedTime?.timeRange ?? "Select Time")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.orange)
                                    
                                    if let status = selectedTime?.status {
                                        Text(status)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(selectedTime?.isRecommended == true ? .green : .gray)
                                    }
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    
                    Rectangle().fill(Color.orange.opacity(0.3)).frame(height: 8)
                    
                    // 3. My Order List
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("My Order")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        ForEach(cart.items) { item in
                            OrderConfirmationItemRow(item: item)
                        }
                    }
                    .padding()
                    
                    // Additional Note & Upsell
                    VStack {
                        Divider()
                        HStack {
                            Text("Additional Note:")
                                .font(.system(size: 12, weight: .medium))
                            
                            Spacer()
                            
                            TextField("Leave a message...", text: .constant(""))
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal)
                        
                        Divider()
                    }
                    
                    // 4. Upsell (Add More)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Craving another QuickBite?")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Go ahead — there's still time to grab one more meal!")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Add More") {
                                dismiss()
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .cornerRadius(20)
                        }
                    }
                    .padding()
                    
                    Rectangle().fill(Color.orange.opacity(0.3)).frame(height: 8)
                    
                    // 5. Payment Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payment Summary")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                        
                        SummaryRow(title: "Quantity", value: "\(cart.totalItemCount)")
                        
                        // ✅ DISPLAY ORIGINAL PRICE AS SUBTOTAL
                        SummaryRow(title: "Subtotal", value: "Rp\(formatPrice(originalSubtotal))")
                        
                        // ✅ DISPLAY DISCOUNT ROW (Red/Orange)
                        if totalDiscountAmount > 0 {
                            HStack {
                                Text("Seller discount")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("-Rp\(formatPrice(Double(totalDiscountAmount)))")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red) // Highlight discount
                            }
                        }
                        
                        SummaryRow(title: "Service fee", value: "+Rp2.500")
                        
                        Divider().padding(.vertical, 4)
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text("Rp\(formatPrice(finalGrandTotal))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            
            // 6. Bottom Bar (Buy Now)
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        
                        // ✅ STRIKETHROUGH ORIGINAL PRICE
                        if totalDiscountAmount > 0 {
                            Text("Rp\(formatPrice(originalGrandTotal))")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                        
                        Text("Rp\(formatPrice(finalGrandTotal))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Button(action: {
                            placeOrder()
                        }) {
                            Text("Buy Now")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
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
        .navigationTitle("Order Confirmation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingTimeSheet) {
            PickUpTimeView(selectedTime: $selectedTime, storeClosingTime: closingTime)
                .environmentObject(calendarManager)
        }
        
        .navigationDestination(isPresented: $navigateToCompleted) {
            OrderPickUpView(
                qrImage: generatedQR,
                orderId: generatedOrderId
            )
            .navigationBarBackButtonHidden(true)
        }
        // ✅ CALL FUNCTIONS ON APPEAR
        .onAppear {
            vm.fetchOrders(for: userId)
            fetchStoreSchedule() // Get store hours
            fetchDiscounts()     // Get discounts
            
            if navState.activeOrderId != nil {
                navState.activitySegment = .inProgress
            }
        }
        
        .onChange(of: navState.activeOrderId) { _ in
            vm.fetchOrders(for: userId)
        }
    }
    
    // --- LOGIC FUNCTIONS ---
    
    // ✅ FIXED FETCH DISCOUNTS (Manual Mapping)
    func fetchDiscounts() {
        guard !cart.restaurantId.isEmpty else { return }
        
        let db = Firestore.firestore()
        let now = Date()
        
        // 1. Fetch ALL active discounts by Time (Avoids strict store_id query failure)
        db.collection("discounts")
            .whereField("end_date_time", isGreaterThan: now)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching discounts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var calculatedTotal: Int = 0
                
                // 2. Loop through results and check store_id MANUALLY
                for doc in documents {
                    let data = doc.data()
                    var docStoreId = ""
                    
                    // Handle Reference vs String mismatch
                    if let storeRef = data["store_id"] as? DocumentReference {
                        docStoreId = storeRef.documentID
                    } else if let storeString = data["store_id"] as? String {
                        docStoreId = storeString.replacingOccurrences(of: "stores/", with: "")
                    }
                    
                    // Check if it matches current restaurant
                    if docStoreId == cart.restaurantId {
                        
                        // Extract needed data manually
                        let amount = data["discount_amount"] as? Int ?? 0
                        let itemId = data["item_id"] as? String ?? ""
                        
                        // Check if this discount applies to any item in our cart
                        if let cartItem = cart.items.first(where: { $0.menuItemId == itemId }) {
                            let itemDiscountTotal = amount * cartItem.quantity
                            calculatedTotal += itemDiscountTotal
                            print("✅ Applied discount \(amount) for item \(cartItem.name)")
                        }
                    }
                }
                
                // Update UI
                DispatchQueue.main.async {
                    self.totalDiscountAmount = calculatedTotal
                }
            }
    }
    
    func fetchStoreSchedule() {
        guard !cart.restaurantId.isEmpty else {
            self.storeStatusText = "Store info unavailable"
            return
        }
        
        let db = Firestore.firestore()
        db.collection("stores").document(cart.restaurantId).getDocument { snapshot, error in
            
            if let data = snapshot?.data(),
               let schedule = data["store_schedule"] as? [String: Any] {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                dateFormatter.locale = Locale(identifier: "en_US")
                let todayName = dateFormatter.string(from: Date())
                
                if let todaySchedule = schedule[todayName] as? [String: Any],
                   let openStr = todaySchedule["open_time"] as? String,
                   let closeStr = todaySchedule["close_time"] as? String {
                    
                    self.closingTime = closeStr
                    
                    checkTimeStatus(open: openStr, close: closeStr)
                    
                } else {
                    self.storeStatusText = "Closed Today"
                    self.isStoreClosed = true
                }
            } else {
                self.storeStatusText = "Schedule unavailable"
            }
        }
    }
    
    func checkTimeStatus(open: String, close: String) {
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentString = timeFormatter.string(from: now)
        
        if currentString < open {
            self.storeStatusText = "Opens at \(open)"
            self.isStoreClosed = true
        } else if currentString > close {
            self.storeStatusText = "Closed (Open until \(close))"
            self.isStoreClosed = true
        } else {
            self.storeStatusText = "Open until \(close)"
            self.isStoreClosed = false
        }
    }
    
    func placeOrder() {
        guard let selectedTime else { return }
        guard !isStoreClosed else { return }
        guard !isPlacingOrder else { return }
        
        isPlacingOrder = true
        
        let service = OrderService()
        let items = cart.items.map { "\($0.quantity)x \($0.name)" }
        
        // Use finalGrandTotal here
        service.createOrder(
            customerName: "Jessica",
            items: items,
            total: Int(finalGrandTotal),
            pickupTime: selectedTime.timeRange,
            tenantId: cart.restaurantId
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
                dismiss()
            }
        }
    }
}

// Subview for Image Loading
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

// Required for Preview
struct OrderConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrderConfirmationView()
                .environmentObject(CartViewModel())
                .environmentObject(CalendarManager())
                .environmentObject(AppNavigationState())
            
        }
    }
}
