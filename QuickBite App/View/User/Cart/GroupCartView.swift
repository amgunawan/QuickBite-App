//
//  GroupCartView.swift
//  QuickBite
//
//  Created by student on 27/11/25.
//

import SwiftUI

struct GroupCartView: View {
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    // Dummy Data untuk anggota lain
    let members = [
        UserMember(name: "Heidy Mudita", username: "@hsutedjo", initial: "H", color: .blue),
        UserMember(name: "Sharon Tan", username: "@sharontan", initial: "S", color: .yellow)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 1. Current User Section (You)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                UserAvatar(initial: "A", color: .orange, isCurrentUser: true)
                                VStack(alignment: .leading) {
                                    Text("Angela (You)")
                                        .font(.headline)
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Ready")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Rp\(formatPrice(cart.totalPrice))")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Text("\(cart.totalItemCount) menu")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Image(systemName: "chevron.up")
                                    .foregroundColor(.gray)
                            }
                            
                            // List Item User (Dari CartViewModel)
                            ForEach(cart.items) { item in
                                GroupCartItemRow(item: item)
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 2. Other Member (Adding Items...)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                UserAvatar(initial: members[0].initial, color: members[0].color)
                                VStack(alignment: .leading) {
                                    Text(members[0].name)
                                        .font(.headline)
                                    HStack(spacing: 4) {
                                        Text("Adding Items...")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Rp42.500") // Dummy
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Text("1 menu")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Image(systemName: "chevron.up")
                                    .foregroundColor(.gray)
                            }
                            
                            // Dummy Item for Heidy
                            HStack(alignment: .top, spacing: 12) {
                                Image("ChickenTeriyakiDonburi") // Pastikan asset ada
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .clipped()
                                VStack(alignment: .leading) {
                                    Text("Chicken Teriyaki Donburi")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Sleeping (Lvl. 0), Classic")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("Rp42.500")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.orange)
                                        .padding(.top, 2)
                                }
                                Spacer()
                                Image(systemName: "bell")
                                    .foregroundColor(.orange)
                                    .padding(8)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // 3. Other Member (Invited / Ready)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                UserAvatar(initial: members[1].initial, color: members[1].color)
                                VStack(alignment: .leading) {
                                    Text(members[1].name)
                                        .font(.headline)
                                    HStack(spacing: 4) {
                                        Text("Invited...")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.orange.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                Spacer()
                            }
                            
                            // Waiting box
                            HStack {
                                Text("Waiting to join...")
                                    .font(.subheadline)
                                    .italic()
                                    .foregroundColor(.gray)
                                Spacer()
                                Image(systemName: "bell")
                                    .foregroundColor(.orange)
                                    .padding(8)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundColor(.gray)
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 120)
                }
                
                // Bottom Bar Group Cart
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        // Icon Basket with Badge
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "basket")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)
                            
                            // Total items (User + Dummy)
                            Text("\(cart.totalItemCount + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .offset(x: 6, y: -6)
                        }
                        .padding(.trailing, 8)
                        
                        Spacer()
                        
                        // Total Price Info
                        VStack(alignment: .trailing) {
                            Text("Rp\(formatPrice(cart.totalPrice))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("(Total: \(formatPrice(cart.totalPrice + 42500)))") // Dummy total
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        // Checkout Button
                        Button(action: {
                            // Action Checkout
                        }) {
                            Text("Checkout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .cornerRadius(25)
                        }
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .navigationTitle("Angela's Group")
            .navigationBarTitleDisplayMode(.inline)
            
            
        }
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
                .background(isCurrentUser ? Color.orange.opacity(0.2) : color.opacity(0.5))
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
            }
        }
    }
}

// Component: Item Row for Group Cart (Simplified)
struct GroupCartItemRow: View {
    let item: CartItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    Button("Change") {}
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
                    
                    // Mini Stepper
                    HStack(spacing: 8) {
                        Image(systemName: "minus.square")
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
        GroupCartView()
            .environmentObject(CartViewModel())
    }
}
