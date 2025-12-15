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
    
    // State untuk sheet waktu
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
    
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Konten Scrollable
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
                                
                                // 👇 PERBAIKAN: Gunakan Rata-rata dari CartViewModel
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
                            // Gunakan Subview agar gambar URL muncul
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
                        
                        SummaryRow(title: "Subtotal", value: "Rp\(formatPrice(cart.totalPrice))")
                        
                        
                        if totalDiscountAmount > 0 {
                            SummaryRow(title: "Seller discount", value: "-Rp\(formatPrice(Double(totalDiscountAmount)))")
                        }
                        
                        SummaryRow(title: "Service fee", value: "+Rp2.500")
                        
                        Divider().padding(.vertical, 4)
                        
                        let finalTotal = cart.totalPrice - Double(totalDiscountAmount) + 2500
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text("Rp\(formatPrice(finalTotal))")
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
                        Text("Rp\(formatPrice(cart.totalPrice))")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .strikethrough()
                        
                        let finalTotal = cart.totalPrice - Double(totalDiscountAmount) + 2500
                        
                        Text("Rp\(formatPrice(finalTotal))")
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
                        
                        // NEW: Little text indicating why it is disabled
                        if isStoreClosed {
                            Text("Store is currently closed")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                        } else if selectedTime == nil {
                            Text("Select time to continue")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color.white)
            }
        }
        .navigationTitle("Order Confirmation")
        .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
            fetchStoreSchedule()
            fetchDiscounts()
        }
    }
    
    // --- LOGIC FUNCTIONS ---
    func fetchDiscounts() {
            guard !cart.restaurantId.isEmpty else { return }
            
            let db = Firestore.firestore()
            
            // Construct path string agar sesuai screenshot: "/stores/AHCqc..."
            let storePath = "/stores/\(cart.restaurantId)"
            
            db.collection("discounts")
                .whereField("store_id", isEqualTo: storePath)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching discounts: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    var calculatedTotal: Int = 0
                    
                    // Decode documents ke DiscountModel
                    let discounts = documents.compactMap { doc -> DiscountModel? in
                        try? doc.data(as: DiscountModel.self)
                    }
                    
                    let activeDiscounts = discounts.filter { $0.isActive }
                    
                    for cartItem in cart.items {

                        if let applicableDiscount = activeDiscounts.first(where: { $0.itemId == cartItem.menuItemId }) {
                            
                            let itemDiscountTotal = applicableDiscount.amount * cartItem.quantity
                            calculatedTotal += itemDiscountTotal
                            
                            print("✅ Applied discount \(applicableDiscount.amount) for item \(cartItem.name)")
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
        let service = OrderService()
        let items = cart.items.map { "\($0.quantity)x \($0.name)" }
        let finalTotal = cart.totalPrice - Double(totalDiscountAmount) + 2500
        service.createOrder(
            customerName: "Jessica",
            items: items,
            total: Int(finalTotal),
            pickupTime: selectedTime?.timeRange ?? "ASAP",
            tenantId: cart.restaurantId
        ) { orderId in
            if let orderId = orderId {
                let qr = QRGenerator().generate(from: orderId)
                self.generatedQR = qr
                self.generatedOrderId = orderId
                self.navigateToCompleted = true
            }
        }
    }
}

// --- SUBVIEW: Cart Item Row (Handles Async Image) ---
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

struct OrderConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrderConfirmationView()
                .environmentObject(CartViewModel())
                .environmentObject(CalendarManager())
        }
    }
}
