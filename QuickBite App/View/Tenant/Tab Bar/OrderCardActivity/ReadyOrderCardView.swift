//
//  ReadyOrderCardView.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI
import Foundation

struct ReadyOrderCardView: View {
    @State private var showConfirmAlert = false
    
    let order: OrderCardViewData
    var onMarkAsCompleted: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.name)
                        .font(.headline)

                    (
                        Text("Pick up at ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        +
                        Text(order.pickupTime)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    )
                }

                Spacer()

                Text("Ready for Pickup")
                    .foregroundColor(.green)
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

            NavigationLink(destination: ScanQRCodeView()) {
                HStack {
                    Text("Scan Order QR")
                        .font(.headline)
                        .foregroundColor(.green.opacity(0.8))
                    Spacer()
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .foregroundColor(.green.opacity(0.8))
                }
                .padding()
                .background(Color.green.opacity(0.15))
                .cornerRadius(UIConst.corner)
            }
            
            Button(action: {
                showConfirmAlert = true
            }) {
                Text("Mark as Completed")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(24)
            }
            .tint(nil)
            .accentColor(nil)
            .alert("Mark Order as Completed?", isPresented: $showConfirmAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Complete") {
                    onMarkAsCompleted?()
                }
            } message: {
                Text("Confirm that this order has been successfully picked up by \(order.name).")
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
