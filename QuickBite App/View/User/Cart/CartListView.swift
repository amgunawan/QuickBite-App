//
//  CartListView.swift
//  QuickBite
//
//  Created by student on 19/11/25.
//

import SwiftUI

struct CartListView: View {
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingCart = false
    
    @State private var itemToEdit: CartItem?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Content List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(cart.items.enumerated()), id: \.element.id) { index, item in
                            CartItemRow(item: item, onChange: {
                                self.itemToEdit = item
                            })
                            .padding(.horizontal)
                            .padding(.vertical, 16)

                            if index < cart.items.count - 1 {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 100) // Ruang untuk footer
                }
                
                CartFooterView(showCart: $showingCart)
            }
            .navigationTitle("My Cart")
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
            .sheet(item: $itemToEdit) { item in
                MenuOptionsView(
                    imageName: item.imageName,
                    name: item.name,
                    salesDescription: "",
                    price: item.basePrice,
                    originalPrice: item.baseOriginalPrice,
                    itemToEdit: item // Pass item untuk mode edit
                )
                .environmentObject(cart)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .background(Color.white)
    }
}

// --- Sub-View: Baris Item Keranjang ---
struct CartItemRow: View {
    let item: CartItem
    let onChange: () -> Void
    
    @EnvironmentObject var cart: CartViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Gambar
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Button("Change") {
                        onChange()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                }
                
                Text(item.optionsDescription)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Spacer()
                
                // Harga dan Stepper
                HStack {
                    Text("Rp\(formatPrice(item.currentPrice))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                    
                    if item.baseOriginalPrice != nil {
                        Text("Rp\(formatPrice(item.originalPrice))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                    
                    Spacer()
                    
                    // Stepper Kecil
                    HStack(spacing: 12) {
                        Button(action: { cart.decrementItem(id: item.id) }) {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange, lineWidth: 1))
                        }
                        
                        Text("\(item.quantity)")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Button(action: { cart.incrementItem(id: item.id) }) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 26, height: 26)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .frame(height: 100) // Tinggi fix agar rapi
    }
}

// --- Sub-View: Footer Keranjang ---
struct CartFooterView: View {
    @EnvironmentObject var cart: CartViewModel
    
    @Binding var showCart: Bool
    
    var body: some View {
        VStack {
            Divider()
                .padding(.bottom, 10)
            
            HStack(spacing: 16) {
                Button(action: {
                    showCart = false
                }) {
                    HStack(spacing: 16) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                                .padding(.trailing, 2)
                            
                            // Badge Count
                            if cart.totalItemCount > 0 {
                                Text("\(cart.totalItemCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                        .frame(width: 44, height: 44)
                        
                        Spacer()
                        // Info Harga
                        VStack(alignment: .trailing, spacing: 2) {
                            if cart.totalOriginalPrice > cart.totalPrice {
                                Text("Rp\(formatPrice(cart.totalOriginalPrice))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .strikethrough()
                            }
                            Text("Rp\(formatPrice(cart.totalPrice))")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                
                // Tombol Checkout
                Button(action: { print("Navigasi ke halaman Checkout") }) {
                    Text("Checkout")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(50)
                }
                
            }
            .padding(.horizontal)
            .background(Color.white)
        }
        .background(Color.white)
    }
    
}

struct CartListView_Previews: PreviewProvider {
    static var previews: some View {
        CartListView()
            .environmentObject(CartViewModel())
    }
}
