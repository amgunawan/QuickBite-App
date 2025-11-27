//
//  OrderConfirmationView.swift
//  QuickBite
//
//  Created by student on 19/11/25.
//

import SwiftUI

struct OrderConfirmationView: View {
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    // State untuk sheet waktu
    @State private var showingTimeSheet = false
    
    // Default selection
    @State private var selectedTime: TimeSlot? = TimeSlot(
        timeRange: "12:00 PM",
        status: "Right After your class! (Recommended)",
        isRecommended: true,
        isWarning: false
    )
    
    @State private var navigateToCompleted = false
    
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
                            Text("Raburi")
                                .font(.headline)
                            Text("Open until 5 PM")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 4) {
                                Text("Estimated Ready in:")
                                    .font(.system(size: 13))
                                Text("12 minutes")
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
                        
                        // Kartu Waktu Terpilih (Satu Opsi Saja)
                        Button(action: { showingTimeSheet = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedTime?.timeRange ?? "Select Time")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.orange) // Selalu orange karena terpilih
                                    
                                    if let status = selectedTime?.status {
                                        Text(status)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(selectedTime?.isRecommended == true ? .green : .gray)
                                    }
                                }
                                Spacer()
                                
                                // Icon Checkmark
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
                            HStack(alignment: .top, spacing: 12) {
                                Image(item.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .clipped()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .semibold))
                                    Text(item.optionsDescription)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                    
                                    HStack {
                                        Text("Rp\(formatPrice(item.currentPrice))")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.orange)
                                        if item.baseOriginalPrice != nil {
                                            Text("Rp\(formatPrice(item.originalPrice))")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                                .strikethrough()
                                        }
                                        Spacer()
                                        Text("x\(item.quantity)")
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    VStack{
                        Divider()
                        // Additional Note Input
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
                        SummaryRow(title: "Seller discount", value: "-Rp5.000")
                        SummaryRow(title: "Service fee", value: "+Rp2.500")
                        
                        Divider().padding(.vertical, 4)
                        
                        let finalTotal = cart.totalPrice - 5000 + 2500
                        
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
                        
                        let finalTotal = cart.totalPrice - 5000 + 2500
                        Text("Rp\(formatPrice(finalTotal))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Button(action: {
                        cart.clearCart()
                        navigateToCompleted = true
                    }) {
                        Text("Buy Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                }
                .padding()
                .background(Color.white)
            }
        }
        .navigationTitle("Order Confirmation")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingTimeSheet) {
            PickUpTimeView(selectedTime: $selectedTime)
        }
        .navigationDestination(isPresented: $navigateToCompleted) {
            OrderCompletedView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct OrderConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrderConfirmationView().environmentObject(CartViewModel())
        }
    }
}
