import SwiftUI

struct EditMenuTenantView: View {

    @Environment(\.dismiss) private var dismiss

    @State var item: MenuItem
    var onSave: (MenuItem) -> Void

    private let minutesChoices = Array(stride(from: 5, through: 120, by: 5))

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        itemPictureSection
                        Divider()

                        itemInformationSection
                        Divider()

                        customizationSection

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .zIndex(1)
            }

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

private extension EditMenuTenantView {
    var itemPictureSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Item Picture")
                .font(.subheadline.weight(.semibold))

            HStack(alignment: .top, spacing: 14) {

                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 10) {

                    // Choose File button
                    Button(action: {}) {
                        HStack {
                            Text("Choose File")
                                .font(.caption.weight(.semibold))
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15), in: Capsule())
                    }

                    // STOCK
                    HStack(spacing: 6) {
                        Text("Current Stock:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Stepper(value: $item.stock, in: 0...999) {
                            Text("\(item.stock)")
                        }
                        .labelsHidden()
                        .frame(width: 100)
                    }
                }
            }
        }
    }
    var itemInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Item Information")
                .font(.subheadline.weight(.semibold))

            // NAME
            VStack(alignment: .leading, spacing: 6) {
                Text("Item Name")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Item name", text: $item.name)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
            }

            // DESCRIPTION
            VStack(alignment: .leading, spacing: 6) {
                Text("Short description")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $item.shortDescription)
                    .frame(minHeight: 90)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
            }

            HStack(spacing: 12) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Base Price (Rp)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("35000", value: $item.price, formatter: NumberFormatter.decimalNoGrouping)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
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
                        RoundedRectangle(cornerRadius: 8)
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
