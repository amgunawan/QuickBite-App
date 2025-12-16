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
    
    // MARK: - ENV
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss
    
    // MARK: - UI STATE
    @State private var showingTimeSheet = false
    
    @State private var storeStatusText: String = "Loading..."
    @State private var isStoreClosed: Bool = false
    @State private var closingTime: String = "22:00"
    
    @State private var totalDiscountAmount: Int = 0
    @State private var selectedTime: TimeSlot? = nil
    
    // MARK: - NAV STATE (FIX TOTAL)
    @State private var createdOrderId: String? = nil
    @State private var goPrepared: Bool = false
    
    @State private var isPlacingOrder: Bool = false
    
    // MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // ================= CONTENT =================
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // 1. INFO TOKO
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "storefront")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange, lineWidth: 1.5)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Pickup At")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(cart.restaurantName.isEmpty ? "Unknown Restaurant" : cart.restaurantName)
                                    .font(.headline)
                                
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
                        
                        sectionDivider()
                        
                        // 2. PICK UP TIME
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
                            
                            Button {
                                showingTimeSheet = true
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedTime?.timeRange ?? "Select Time")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.orange)
                                        
                                        if let status = selectedTime?.status {
                                            Text(status)
                                                .font(.system(size: 13))
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
                        
                        sectionDivider()
                        
                        // 3. MY ORDER
                        VStack(alignment: .leading, spacing: 16) {
                            Text("My Order")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            ForEach(cart.items) { item in
                                OrderConfirmationItemRow(item: item)
                            }
                        }
                        .padding()
                        
                        sectionDivider()
                        
                        // 4. PAYMENT SUMMARY
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Payment Summary")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            SummaryRow(title: "Quantity", value: "\(cart.totalItemCount)")
                            SummaryRow(title: "Subtotal", value: "Rp\(formatPrice(cart.totalPrice))")
                            
                            if totalDiscountAmount > 0 {
                                SummaryRow(
                                    title: "Seller discount",
                                    value: "-Rp\(formatPrice(Double(totalDiscountAmount)))"
                                )
                            }
                            
                            SummaryRow(title: "Service fee", value: "+Rp2.500")
                            
                            Divider()
                            
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
                        .padding(.bottom, 120)
                    }
                }
                
                // ================= BUY NOW =================
                VStack {
                    Divider()
                    
                    Button {
                        placeOrderAndGoPrepared()
                    } label: {
                        Text(isPlacingOrder ? "Processing..." : "Buy Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                (isStoreClosed || selectedTime == nil || isPlacingOrder)
                                ? Color.gray
                                : Color.orange
                            )
                            .cornerRadius(24)
                    }
                    .disabled(isStoreClosed || selectedTime == nil || isPlacingOrder)
                    .padding()
                }
                .background(Color.white)
            }
            
            // 🔥 NAVIGATION FIX (ANTI BUG)
            .navigationDestination(isPresented: $goPrepared) {
                if let orderId = createdOrderId {
                    OrderPreparedView(orderId: orderId)
                }
            }
            
            .navigationTitle("Order Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTimeSheet) {
                PickUpTimeView(
                    selectedTime: $selectedTime,
                    storeClosingTime: closingTime
                )
                .environmentObject(calendarManager)
            }
            .onAppear {
                fetchStoreSchedule()
                fetchDiscounts()
            }
        }
    }
    
    // MARK: - HELPERS
    private func sectionDivider() -> some View {
        Rectangle()
            .fill(Color.orange.opacity(0.25))
            .frame(height: 8)
            .padding(.vertical, 2)
    }
    
    // MARK: - FIRESTORE LOGIC
    private func placeOrderAndGoPrepared() {
        guard !isPlacingOrder else { return }
        guard let selectedTime else { return }
        
        isPlacingOrder = true
        
        let finalTotal = cart.totalPrice - Double(totalDiscountAmount) + 2500
        let items = cart.items.map { "\($0.quantity)x \($0.name)" }
        
        OrderService().createOrder(
            customerName: "Jessica",
            items: items,
            total: Int(finalTotal),
            pickupTime: selectedTime.timeRange,
            tenantId: cart.restaurantId
        ) { orderId in
            
            DispatchQueue.main.async {
                self.isPlacingOrder = false
            }
            
            guard let orderId else {
                print("❌ FAILED CREATE ORDER")
                return
            }
            
            DispatchQueue.main.async {
                self.createdOrderId = orderId
                self.goPrepared = true
                cart.clearCart()
            }
        }
    }
    
    private func fetchDiscounts() {
        guard !cart.restaurantId.isEmpty else { return }
        
        Firestore.firestore()
            .collection("discounts")
            .whereField("store_id", isEqualTo: "/stores/\(cart.restaurantId)")
            .getDocuments { snapshot, _ in
                let total = snapshot?.documents.compactMap {
                    try? $0.data(as: DiscountModel.self)
                }.filter { $0.isActive }.reduce(0) {
                    $0 + ($1.amount)
                } ?? 0
                
                DispatchQueue.main.async {
                    self.totalDiscountAmount = total
                }
            }
    }
    
    private func fetchStoreSchedule() {
        Firestore.firestore()
            .collection("stores")
            .document(cart.restaurantId)
            .getDocument { snapshot, _ in
                self.storeStatusText = snapshot?.exists == true ? "Open" : "Closed"
            }
    }
}

// ================= SUBVIEW =================

struct OrderConfirmationItemRow: View {
    let item: CartItemModel
    @State private var imageURL: URL?
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: imageURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(item.name).fontWeight(.semibold)
                Text("Rp\(formatPrice(item.currentPrice))")
                    .foregroundColor(.orange)
            }
        }
        .onAppear {
            if item.imageName.starts(with: "http") {
                imageURL = URL(string: item.imageName)
            }
        }
    }
}
