//
//  OrderFoundView.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI

struct OrderFoundSheet: View {

    let order: OrderCardViewData
    var onCancel: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // TITLE
            Text("Order Found!")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 10)

            Divider()

            // ORDER INFO
            VStack(alignment: .leading, spacing: 8) {
                Text(order.name)
                    .font(.headline)

                Text("Pick up at \(order.pickupTime)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                ForEach(order.items, id: \.self) { item in
                    Text(item)
                }
            }

            Divider()

            Text("Total: \(order.total)")
                .fontWeight(.bold)

            Spacer()

            // BUTTON ACTIONS
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(12)
                }

                Button(action: onConfirm) {
                    Text("Confirm & Complete")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(UIConst.brandOrange)
                        .cornerRadius(12)
                }
            }
            .padding(.bottom, 12)
        }
        .padding()
        .background(Color.white)
    }
}
