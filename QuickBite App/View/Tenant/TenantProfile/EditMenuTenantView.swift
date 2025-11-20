//
//  EditMenuTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 10/11/25.
//

import SwiftUI

struct EditMenuTenantView: View {

    @Environment(\.dismiss) private var dismiss

    @State var item: MenuItem
    var onSave: (MenuItem) -> Void

    private let minutesChoices = Array(stride(from: 5, through: 120, by: 5))

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // === HEADER ===
                HStack {
                    Text("Edit Item")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .zIndex(2)

                // === CONTENT ===
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {

                        itemPictureSection
                        Divider()

                        itemInformationSection
                        Divider()

                        customizationSection

                        Spacer(minLength: 150)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }

            // === SAVE BUTTON ===
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button {
                        onSave(item)
                        dismiss()
                    } label: {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
    }
}

// MARK: - SECTIONS
private extension EditMenuTenantView {

    // ============================
    //      ITEM PICTURE SECTION
    // ============================
    var itemPictureSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Item Picture")
                .font(.system(size: 17, weight: .semibold))

            HStack(alignment: .top, spacing: 14) {

                // Preview
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 98, height: 98)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 10) {

                    // Top Row
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            Text("Choose File")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.15))
                                )
                        }
                        .fixedSize()

                        Text("katsu_shirokara.JPG")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    Text("A clear, square image looks best")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    // Stock
                    HStack(spacing: 6) {
                        Text("Current Stock:")
                            .font(.system(size: 15))

                        Stepper(value: $item.stock, in: 0...999) {
                            Text("\(item.stock)")
                                .font(.system(size: 16))
                                .frame(width: 45)
                        }
                        .labelsHidden()
                    }
                    .padding(.top, 4)

                }

                Spacer()
            }
        }
    }

    // ============================
    //      ITEM INFORMATION
    // ============================
    var itemInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Item Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Item Name")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Enter name", text: $item.name)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .font(.system(size: 15))
            }

            // Description
            VStack(alignment: .leading, spacing: 6) {
                Text("Short description")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ZStack(alignment: .topLeading) {
                    if item.shortDescription.isEmpty {
                        Text("Enter short description...")
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .font(.system(size: 15))
                    }

                    TextEditor(text: $item.shortDescription)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(minHeight: 90)
                        .font(.system(size: 15))
                        .background(Color.clear)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
            }

            // Price + Prep Time
            HStack(spacing: 12) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Base Price (Rp)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("35000", value: $item.price, formatter: NumberFormatter.decimalNoGrouping)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemBackground))
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Prep Time (Minimum)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Picker("", selection: $item.prepMinutes) {
                            ForEach(minutesChoices, id: \.self) { m in
                                Text("\(m)").tag(m)
                            }
                        }
                        .pickerStyle(.menu)

                        Text("mins")
                            .foregroundColor(.secondary)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }

            Text("Customer sees: \(item.prepMinutes + 10) mins (10 min prep + 10 min buffer)")
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.12))
                )
                .foregroundColor(.secondary)

            Text("Time must be accurate within 10 mins tolerance to avoid penalty")
                .font(.caption2)
                .foregroundColor(.red)
        }
    }

    // ============================
    //      CUSTOMIZATION
    // ============================
    var customizationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Customization Options")
                .font(.subheadline.weight(.semibold))

            Text("Add size, toppings, or spice level here (coming soon).")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

extension NumberFormatter {
    static var decimalNoGrouping: NumberFormatter {
        let n = NumberFormatter()
        n.numberStyle = .none
        return n
    }
}

#Preview {
    EditMenuTenantView(
        item: MenuItem(
            name: "Sample Item",
            price: 35000,
            stock: 10,
            shortDescription: "Dummy description for preview.",
            prepMinutes: 15,
            imageName: "ChickenKatsuShirokaraRamen"
        ),
        onSave: { _ in }
    )
}
