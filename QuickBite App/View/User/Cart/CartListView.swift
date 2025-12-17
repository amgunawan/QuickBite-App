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

    @State private var itemToEdit: CartItemModel?
    @State private var showOrderConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // ======================
                // CART ITEMS
                // ======================
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(cart.items.enumerated()), id: \.element.id) { index, item in
                            CartItemRow(item: item) {
                                itemToEdit = item
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 16)

                            if index < cart.items.count - 1 {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 120)
                }

                // ======================
                // FOOTER
                // ======================
                CartFooterView {
                    showOrderConfirmation = true
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }

            // ======================
            // EDIT ITEM (FIXED)
            // ======================
            .sheet(item: $itemToEdit) { cartItem in
                // ✅ FIX: Use a helper function here instead of 'let tempMenuItem = ...'
                MenuOptionsView(
                    restaurantName: cart.restaurantName,
                    restaurantId: cart.restaurantId,
                    item: convertToMenuItem(cartItem), // Call function here
                    finalPrice: cartItem.basePrice,
                    originalPrice: cartItem.baseOriginalPrice,
                    itemToEdit: cartItem
                )
                .environmentObject(cart)
            }

            // ======================
            // GO TO ORDER CONFIRMATION
            // ======================
            .fullScreenCover(isPresented: $showOrderConfirmation) {
                NavigationStack{
                    OrderConfirmationView()
                        .environmentObject(cart)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .background(Color.white)
    }
    
    // ✅ HELPER FUNCTION TO FIX THE ERROR
    func convertToMenuItem(_ cartItem: CartItemModel) -> MenuItem {
        return MenuItem(
            itemId: cartItem.menuItemId, // Use stored menuItemId
            name: cartItem.name,
            description: nil,
            price: Int(cartItem.basePrice),
            category: nil,
            imageURL: cartItem.imageName,
            defaultStock: nil,
            prepTimeMinutes: cartItem.prepTime,
            options: nil // Options are handled via itemToEdit in MenuOptionsView
        )
    }
}

//////////////////////////////////////////////////////////////
/// CART ITEM ROW (Unchanged)
//////////////////////////////////////////////////////////////
struct CartItemRow: View {

    let item: CartItemModel
    let onChange: () -> Void

    @EnvironmentObject var cart: CartViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // IMAGE
            if let url = URL(string: item.imageName),
               item.imageName.starts(with: "http") {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text(item.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)

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

                Spacer()

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

                    // STEPPER
                    HStack(spacing: 10) {
                        Button {
                            cart.decrementItem(id: item.id)
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                        }

                        Text("\(item.quantity)")
                            .font(.system(size: 14, weight: .bold))

                        Button {
                            cart.incrementItem(id: item.id)
                        } label: {
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

//////////////////////////////////////////////////////////////
/// FOOTER (Unchanged)
//////////////////////////////////////////////////////////////
struct CartFooterView: View {

    @EnvironmentObject var cart: CartViewModel
    var onCheckout: () -> Void

    var body: some View {
        VStack {
            Divider()

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

                VStack(alignment: .leading) {
                    if cart.totalOriginalPrice > cart.totalPrice {
                        Text("Rp\(formatPrice(cart.totalOriginalPrice))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }

                    Text("Rp\(formatPrice(cart.totalPrice))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                }

                Button {
                    onCheckout()
                } label: {
                    Text("Checkout")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(20)
                }
            }
            .padding()
            .background(Color.white)
        }
    }
}

struct CartListView_Previews: PreviewProvider {
    static var previews: some View {
        CartListView()
            .environmentObject(CartViewModel())
            .environmentObject(AppNavigationState())
    }
}
