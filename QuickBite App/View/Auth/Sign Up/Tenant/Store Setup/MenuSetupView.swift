//
//  MenuSetupView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI

struct MenuSetupView: View {

    // MARK: - Menu Data
    @State private var sections: [MenuSectionModel] = []

    // MARK: - UI States
    @State private var editingIndex: EditingItem? = nil

    struct EditingItem: Identifiable {
        let id = UUID()
        let sec: Int
        let row: Int
    }

    var body: some View {
        VStack(spacing: 20) {

            MenuHeader(
                step: 2,
                title: "Build your Quickbite Store",
                subtitle: "Configure your store’s menu and branding"
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    Text("Menu Sections")
                        .font(.headline)

                    if sections.isEmpty {
                        emptyMenuPlaceholder
                    }

                    ForEach(sections.indices, id: \.self) { secIdx in
                        simpleSectionView(secIdx)
                    }

                    if !sections.isEmpty {
                        Button {
                            sections.append(MenuSectionModel(title: "", items: []))
                        } label: {
                            Text("Add New Section")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.orange, in: Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }

            // ✅ FINISH BUTTON WITH VALIDATION
            NavigationLink(destination: OnboardingView()) {
                Text("Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        canFinish ? Color.orange : Color.gray.opacity(0.4),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .padding(.horizontal)
            .disabled(!canFinish)
        }

        .sheet(item: $editingIndex) { edit in
            AddMenuItemOverlay { newItem in
                sections[edit.sec].items[edit.row] = newItem
                editingIndex = nil
            }
            .presentationDetents([.fraction(0.92)])
            .presentationCornerRadius(22)
        }
    }

    // MARK: - ✅ VALIDATION LOGIC (YOUR EXACT RULES)
    private var canFinish: Bool {

        if sections.isEmpty { return false }

        for section in sections {

            // Section name must NOT be empty
            if section.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }

            // Section must have at least 1 item
            if section.items.isEmpty {
                return false
            }

            for item in section.items {

                // Item name NOT empty
                if item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return false
                }

                // shortDescription ✅ allowed empty

                // Price must be > 0
                if item.price <= 0 {
                    return false
                }

                // Prep time must be > 0
                if item.prepMinutes <= 0 {
                    return false
                }
            }
        }

        return true
    }

    // MARK: - EMPTY PLACEHOLDER
    private var emptyMenuPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.system(size: 34))
                .foregroundColor(.orange)

            Text("Your menu is currently empty")
                .foregroundColor(.secondary)

            Button {
                sections.append(MenuSectionModel(title: "", items: []))
            } label: {
                Text("Add Menu Section")
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.orange, in: Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4)))
    }

    // MARK: - SECTION VIEW
    @ViewBuilder
    private func simpleSectionView(_ secIdx: Int) -> some View {
        let section = sections[secIdx]

        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                TextField("Enter section name",
                          text: bindingTitle(for: secIdx))
                    .font(.headline)

                Button {
                    addItem(in: secIdx)
                } label: {
                    Text("Add Item")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.orange, in: Capsule())
                }
            }

            Divider()

            ForEach(section.items.indices, id: \.self) { rowIdx in
                MenuRow(item: section.items[rowIdx]) {
                    editingIndex = EditingItem(sec: secIdx, row: rowIdx)
                }
            }
        }
    }

    // MARK: - Binding Section Title
    private func bindingTitle(for index: Int) -> Binding<String> {
        Binding(
            get: { sections[index].title },
            set: { sections[index].title = $0 }
        )
    }

    // MARK: - ADD ITEM (INVALID BY DEFAULT)
    private func addItem(in secIdx: Int) {

        let newItem = MenuItem(
            name: "",
            price: 0,
            stock: 10,
            shortDescription: "",
            prepMinutes: 0,
            imageName: "placeholder"
        )

        sections[secIdx].items.insert(newItem, at: 0)
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

#Preview {
    MenuSetupView()
}
