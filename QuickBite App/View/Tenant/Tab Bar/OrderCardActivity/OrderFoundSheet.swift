//
//  OrderFoundSheet.swift
//  QuickBite App
//
//  Created by jessica tedja on 26/11/25.
//

import SwiftUI

struct OrderFoundSheet: View {

    let order: OrderCardViewData
    var onCancel: () -> Void
    var onConfirm: () -> Void

    /// Order dianggap invalid kalau namanya "Order Invalid"
    private var isInvalidOrder: Bool {
        order.name == "Order Invalid"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // MARK: - TITLE
            Text(isInvalidOrder ? "Invalid Order" : "Order Found!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isInvalidOrder ? .red : .primary)
                .padding(.top, 10)

            Divider()

            // MARK: - ORDER INFO
            VStack(alignment: .leading, spacing: 8) {

                Text(order.name)
                    .font(.headline)
                    .foregroundColor(isInvalidOrder ? .red : .primary)

                if !isInvalidOrder {
                    Text("Pick up at \(order.pickupTime)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // MARK: - ITEMS
            VStack(alignment: .leading, spacing: 6) {
                ForEach(order.items, id: \.self) { item in
                    Text("• \(item)")
                        .foregroundColor(isInvalidOrder ? .red : .primary)
                }
            }

            Divider()

            // MARK: - TOTAL
            if !isInvalidOrder {
                Text("Total: \(order.total)")
                    .fontWeight(.bold)
            }

            Spacer()

            // MARK: - ACTION BUTTONS
            HStack(spacing: 12) {

                // CANCEL BUTTON
                Button(action: onCancel) {
                    Text(isInvalidOrder ? "Close" : "Cancel")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(12)
                }

                // CONFIRM BUTTON (ONLY IF VALID)
                if !isInvalidOrder {
                    Button(action: onConfirm) {
                        Text("Confirm & Complete")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(UIConst.brandOrange)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .padding()
        .background(Color.white)
    }
}
