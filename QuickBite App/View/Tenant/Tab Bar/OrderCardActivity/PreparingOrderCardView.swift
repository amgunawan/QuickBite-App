//
//  PreparingOrderCardView.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI
import Foundation


struct PreparingOrderCardView: View {
    @State private var showConfirmAlert = false
    
    let order: OrderCardViewData
    var onMarkAsReady: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.name)
                        .font(.headline)
                    Text("Pick up at \(order.pickupTime)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Spacer()
                Text("Preparing")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            ForEach(order.items, id: \.self) { item in
                Text(item)
                    .font(.subheadline)
            }
            
            Divider()
            
            Text("Total: \(order.total)")
                .fontWeight(.bold)
            
            Divider()
            
            Button(action: {
                showConfirmAlert = true
            }) {
                Text("Mark as Ready")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(24)
            }
            .alert("Mark Order as Ready?", isPresented: $showConfirmAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Ready") {
                    onMarkAsReady?()
                }
            } message: {
                Text("This will notify \(order.name) that their order is ready for pickup.")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5))
                .background(Color.white.cornerRadius(16))
        )
    }
}
