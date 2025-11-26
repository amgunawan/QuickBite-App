//
//  ReadyOrderCardView.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI
import Foundation

struct ReadyOrderCardView: View {

    let order: OrderCardViewData   // hanya 1 parameter

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

                Text("Ready for Pickup")
                    .font(.subheadline)
                    .foregroundColor(Color.green)
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
                        .foregroundColor(Color.green.opacity(0.8))
                    Spacer()
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .foregroundColor(Color.green.opacity(0.8))
                }
                .padding()
                .background(Color.green.opacity(0.15))
                .cornerRadius(UIConst.corner)
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


#Preview {
    ReadyOrderCardView(
        order: OrderCardViewData(
            name: "Sharon Tan",
            pickupTime: "12:00 PM",
            items: ["2x Chicken Katsu Shirokara Ramen", "1x Cold Ocha"],
            total: "Rp 83.000"
        )
    )
}
