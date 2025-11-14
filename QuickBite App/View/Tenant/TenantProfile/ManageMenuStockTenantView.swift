//
//  ManageMenuStockView.swift
//  QuickBite App
//
//  Created by jessica tedja on 05/11/25.
//

import SwiftUI

enum StockStatus: String, Codable {
    case inStock = "In Stock"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
}

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var price: Int
    var stock: Int
    var shortDescription: String
    var prepMinutes: Int
    var imageName: String

    var status: StockStatus {
        if stock <= 0 { return .outOfStock }
        if stock <= 5 { return .lowStock }
        return .inStock
    }
}

struct MenuSectionModel: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var items: [MenuItem]
}

struct ManageMenuStockTenantView: View {
    @State private var sections: [MenuSectionModel] = demoDataAssets

    @State private var editingPath: (sec: Int, row: Int)? = nil
    @State private var showEditSheet = false
    @State private var showAddSection = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { secIdx, section in
                        SectionCard(
                            title: section.title,
                            onAddItem: { addItem(in: secIdx) }
                        ) {
                            VStack(spacing: 10) {
                                ForEach(Array(section.items.enumerated()), id: \.element.id) { rowIdx, item in
                                    MenuRow(item: item) {
                                        editingPath = (secIdx, rowIdx)
                                        showEditSheet = true
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        showAddSection = true
                    } label: {
                        Text("Add New Section")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange, in: Capsule())
                    }
                    .padding(.top, 6)
                    .padding(.horizontal)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Manage Menu & Stock")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showEditSheet) {
            if let (sec, row) = editingPath {
                EditMenuItemSheetAssets(
                    item: sections[sec].items[row],
                    onSave: { updated in
                        sections[sec].items[row] = updated
                        showEditSheet = false
                    },
                    onClose: { showEditSheet = false }
                )
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(22)
            }
        }
        .alert("Add New Section", isPresented: $showAddSection) {
            Button("Add") { sections.append(.init(title: "New Section", items: [])) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A blank section named “New Section” will be created. You can rename it later.")
        }
    }

    private func addItem(in secIdx: Int) {
        let demo = MenuItem(
            name: "New Item",
            price: 20000,
            stock: 10,
            shortDescription: "Describe your tasty item here.",
            prepMinutes: 15,
            imageName: "placeholder" // ganti ke asset default milikmu
        )
        sections[secIdx].items.insert(demo, at: 0)
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    let onAddItem: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(action: onAddItem) {
                    Text("Add Item")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange, in: Capsule())
                }
            }
            .padding(.horizontal)

            Divider().overlay(Color.orange.opacity(0.25)).padding(.horizontal)

            content
                .padding(.horizontal)
        }
    }
}

private struct MenuRow: View {
    let item: MenuItem
    let onEdit: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                StatusBadge(status: item.status)

                Text("Rp\(formatRupiah(item.price))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }

            Spacer()

            Button(action: onEdit) {
                Text("Edit")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15), in: Capsule())
            }
        }
    }
}

private struct StatusBadge: View {
    let status: StockStatus
    var body: some View {
        let (textColor, bg): (Color, Color) = {
            switch status {
            case .inStock:    return (.white, Color.green)
            case .lowStock:   return (.black, Color.yellow.opacity(0.9))
            case .outOfStock: return (.white, Color.red)
            }
        }()

        return Text(status.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bg, in: Capsule())
    }
}

private struct EditMenuItemSheetAssets: View {
    @State var item: MenuItem
    var onSave: (MenuItem) -> Void
    var onClose: () -> Void

    private let minutesChoices: [Int] = Array(stride(from: 5, through: 120, by: 5))

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Edit Item")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 6)

                    Group {
                        Text("Item Picture").font(.subheadline.weight(.semibold))
                        HStack(alignment: .top, spacing: 12) {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 8) {
                                LabeledField(title: "Asset Image Name") {
                                    TextField("asset_name", text: $item.imageName)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding(8)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                                }
                                HStack(spacing: 6) {
                                    Text("Current Stock:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Stepper(value: $item.stock, in: 0...999) {
                                        Text("\(item.stock)")
                                    }
                                    .labelsHidden()
                                    .frame(width: 100, alignment: .leading)
                                }
                            }
                        }
                    }

                    Divider().padding(.vertical, 4)

                    Group {
                        Text("Item Information").font(.subheadline.weight(.semibold))

                        VStack(alignment: .leading, spacing: 8) {
                            LabeledField(title: "Item Name") {
                                TextField("Item name", text: $item.name)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                            }

                            LabeledField(title: "Short description") {
                                TextEditor(text: $item.shortDescription)
                                    .frame(minHeight: 92)
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                            }

                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Base Price (Rp)")
                                        .font(.caption).foregroundColor(.secondary)
                                    TextField("35000", value: $item.price, formatter: NumberFormatter.decimalNoGrouping)
                                        .keyboardType(.numberPad)
                                        .padding(10)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Prep Time (Minimum)")
                                        .font(.caption).foregroundColor(.secondary)
                                    HStack {
                                        Picker("", selection: $item.prepMinutes) {
                                            ForEach(minutesChoices, id: \.self) { m in
                                                Text("\(m)").tag(m)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        Text("mins").foregroundColor(.secondary)
                                    }
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                                }
                            }

                            Text("Customer sees: \(max(item.prepMinutes + 5, item.prepMinutes + 10)) mins (10 min prep + 10 min buffer)")
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange.opacity(0.12)))
                                .foregroundColor(.secondary)

                            Text("Time must be accurate within 10 mins tolerance to avoid penalty")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }

                    Divider().padding(.vertical, 4)

                    Text("Customization Options")
                        .font(.subheadline.weight(.semibold))
                    Text("Add size, toppings, or spice level here (coming soon).")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer(minLength: 80)
                }
                .padding(16)
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button {
                        onSave(item)
                    } label: {
                        Text("Save Changes")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onClose() } label: {
                        Image(systemName: "xmark").font(.body.weight(.semibold))
                    }
                    .tint(.secondary)
                }
            }
        }
    }
}

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundColor(.secondary)
            content
        }
    }
}

private func formatRupiah(_ value: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.groupingSeparator = "."
    f.maximumFractionDigits = 0
    return f.string(from: NSNumber(value: value)) ?? "\(value)"
}

private extension NumberFormatter {
    static var decimalNoGrouping: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .none
        nf.maximumFractionDigits = 0
        return nf
    }()
}

private let demoDataAssets: [MenuSectionModel] = [
    .init(title: "Shirokara Ramen", items: [
        .init(name: "Chicken Katsu Shirokara Ramen",
              price: 35000, stock: 3,
              shortDescription: "Ramen noodle, chicken katsu, tamago, with shirokara soupa",
              prepMinutes: 15, imageName: "ChickenKatsuShirokaraRamen"),
        .init(name: "Chicken Teriyaki Shirokara Ramen",
              price: 35000, stock: 12,
              shortDescription: "Teriyaki chicken, ramen, narutomaki.",
              prepMinutes: 15, imageName: "ChickenTeriyakiShirokaraRamen")
    ]),
    .init(title: "Donburi", items: [
        .init(name: "Chicken Teriyaki Donburi", price: 42500, stock: 0,
              shortDescription: "Rice bowl with teriyaki chicken.", prepMinutes: 20, imageName: "ChickenTeriyakiDonburi"),
        .init(name: "Chicken Katsu Curry Rice", price: 42500, stock: 0,
              shortDescription: "Katsu curry rice, medium spice.", prepMinutes: 20, imageName: "ChickenKatsuCurryRice"),
        .init(name: "Katsutama Donburi", price: 37500, stock: 9,
              shortDescription: "Egg-over katsu rice bowl.", prepMinutes: 15, imageName: "KatsutamaDonburi"),
        .init(name: "Chicken Katsu Donburi", price: 42500, stock: 8,
              shortDescription: "Classic katsu don.", prepMinutes: 15, imageName: "ChickenKatsuDonburi")
    ])
]

#Preview {
    ManageMenuStockTenantView()
}
