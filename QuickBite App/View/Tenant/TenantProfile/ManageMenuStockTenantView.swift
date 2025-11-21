//
//  ManageMenuTenantView.swift
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

// IMPORTANT — TIDAK ADA customizationGroups DI SINI
struct MenuItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var price: Int
    var stock: Int
    var shortDescription: String
    var prepMinutes: Int
    var imageName: String
    var imageFileName: String = "default.jpg"
    var customizationGroups: [CustomizationGroup] = []
    var status: StockStatus {
        if stock <= 0 { return .outOfStock }
        if stock <= 5 { return .lowStock }
        return .inStock
    }
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
           return lhs.id == rhs.id
       }

       // MARK: - Hashable Manual
       func hash(into hasher: inout Hasher) {
           hasher.combine(id)
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
                                        DispatchQueue.main.async {
                                            showEditSheet = true
                                        }
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
                    .padding(.horizontal)
                    .padding(.top, 6)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Manage Menu & Stock")
            .navigationBarTitleDisplayMode(.inline)

        // SHEET — EDIT PAGE
        .sheet(isPresented: $showEditSheet) {
            if let (sec, row) = editingPath {
                EditMenuTenantView(
                    item: sections[sec].items[row],
                    onSave: { updated in
                        sections[sec].items[row] = updated
                        showEditSheet = false
                    }
                )
                .background(.white)
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(22)
            }
        }

        // POPUP ADD SECTION
        .alert("Add New Section", isPresented: $showAddSection) {
            Button("Add") {
                sections.append(.init(title: "New Section", items: []))
            }
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
            imageName: "placeholder"
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

            Divider().overlay(Color.orange.opacity(0.25))
                .padding(.horizontal)

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

            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {

                Text(item.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)

                StatusBadge(status: item.status)

                Text("Rp\(formatRupiah(item.price))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }

            Spacer()

            Button(action: { onEdit() }) {
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
            case .inStock: return (.white, .green)
            case .lowStock: return (.black, .yellow.opacity(0.9))
            case .outOfStock: return (.white, .red)
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

private func formatRupiah(_ value: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.groupingSeparator = "."
    return f.string(from: NSNumber(value: value)) ?? "\(value)"
}

// --- TEMP DATA ---
private let demoDataAssets: [MenuSectionModel] = [
    MenuSectionModel(title: "Shirokara Ramen", items: [
        MenuItem(
            name: "Chicken Katsu Shirokara Ramen",
            price: 35000,
            stock: 3,
            shortDescription: "Ramen noodle, chicken katsu, tamago, with shirokara soupa",
            prepMinutes: 15,
            imageName: "ChickenKatsuShirokaraRamen"
        ),
        MenuItem(
            name: "Chicken Teriyaki Shirokara Ramen",
            price: 35000,
            stock: 12,
            shortDescription: "Teriyaki chicken, ramen, narutomaki.",
            prepMinutes: 15,
            imageName: "ChickenTeriyakiShirokaraRamen"
        )
    ]),

    MenuSectionModel(title: "Donburi", items: [
        MenuItem(
            name: "Chicken Teriyaki Donburi",
            price: 42500,
            stock: 0,
            shortDescription: "Rice bowl with teriyaki chicken.",
            prepMinutes: 20,
            imageName: "ChickenTeriyakiDonburi"
        ),
        MenuItem(
            name: "Chicken Katsu Curry Rice",
            price: 42500,
            stock: 0,
            shortDescription: "Katsu curry rice, medium spice.",
            prepMinutes: 20,
            imageName: "ChickenKatsuCurryRice"
        ),
        MenuItem(
            name: "Katsutama Donburi",
            price: 37500,
            stock: 12,
            shortDescription: "Katsutama.",
            prepMinutes: 20,
            imageName: "KatsutamaDonburi"
        ),
        MenuItem(
            name: "Chicken Katsu Donburi",
            price: 37500,
            stock: 12,
            shortDescription: "Chicken Katsu.",
            prepMinutes: 20,
            imageName: "ChickenKatsuDonburi"
        )
    ])
]

#Preview {
    ManageMenuStockTenantView()
}
