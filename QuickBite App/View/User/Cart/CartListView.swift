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
    @State private var itemToEdit: CartItemModel?
    @State private var showOrderConfirmation = false
    
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
                
                CartFooterView(showCart: $showingCart, onCheckout: {
                    showOrderConfirmation = true
                })
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
            .sheet(item: $itemToEdit) { cartItem in
                
                // 1. Kita harus "Membungkus ulang" data Cart menjadi MenuItemModel
                // agar MenuOptionsView mau menerimanya.
                let tempMenuItem = MenuItemModel(
                    id: cartItem.id.uuidString,
                    name: cartItem.name,
                    description: nil, // Deskripsi tidak disimpan di cart
                    price: Int(cartItem.basePrice),
                    category: nil,
                    imageURL: cartItem.imageName,
                    options: nil // ⚠️ Catatan: Opsi dinamis tidak akan muncul saat edit dari cart
                )
                
                // 2. Panggil Init yang BARU
                MenuOptionsView(
                    restaurantName: cart.restaurantName, // Pass info from Cart
                    restaurantId: cart.restaurantId,
                    item: tempMenuItem,
                    finalPrice: cartItem.basePrice,
                    originalPrice: cartItem.baseOriginalPrice,
                    itemToEdit: cartItem
                )
                .environmentObject(cart)
            }
            .fullScreenCover(isPresented: $showOrderConfirmation) {
                NavigationStack {
                    OrderConfirmationView() // Pastikan View ini ada di project kamu
                        .environmentObject(cart)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    showOrderConfirmation = false
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .background(Color.white)
    }
}

// --- Sub-View: Baris Item Keranjang ---
struct CartItemRow: View {
    let item: CartItemModel
    let onChange: () -> Void
    
    @EnvironmentObject var cart: CartViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // AsyncImage untuk URL
            if let url = URL(string: item.imageName), item.imageName.starts(with: "http") {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
            } else {
                // Fallback Asset Lokal
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .clipped()
            }
            
            // Info Item
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
                    
                    if let original = item.baseOriginalPrice {
                        Text("Rp\(formatPrice(original))")
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
        .frame(height: 100)
    }
}

// --- Sub-View: Footer Keranjang ---
struct CartFooterView: View {
    @EnvironmentObject var cart: CartViewModel
    @Binding var showCart: Bool
    var onCheckout: () -> Void

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
                            Image(systemName: "basket")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                                .padding(.trailing, 2)
                            
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
                
                Button(action: {
                    onCheckout()
                }) {
                    Text("Checkout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(20)
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
