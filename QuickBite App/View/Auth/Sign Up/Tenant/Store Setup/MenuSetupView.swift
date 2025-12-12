//
//  MenuSetupView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI

struct MenuSetupView: View {
    @EnvironmentObject var storeVM: StoreRegistrationViewModel
    @EnvironmentObject var authVM: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Menu Data
    @State private var sections: [MenuSectionModel] = []

    // MARK: - UI States
    @State private var editingIndex: EditingItem? = nil
    @State private var isSubmitting = false

    struct EditingItem: Identifiable {
        let id = UUID()
        let sec: Int
        let row: Int
    }

    var body: some View {
        VStack(spacing: 0) {
            MenuHeader(
                step: 2,
                title: "Build your Quickbite Store",
                subtitle: "Configure your store’s menu and branding"
            )
            .padding(.bottom, 8)

            // Content area
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
            .frame(maxHeight: UIScreen.main.bounds.height * 0.55)
            .clipped()
            .background(Color.clear)

            Spacer(minLength: 8)

            // Debug panel
            HStack {
                Text("canFinish: \(canFinish ? "YES" : "NO")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(isSubmitting ? "Submitting..." : "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 6)

            // Finish button separated into a builder
            finishButton()
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        } // VStack
        .onAppear {
            print("[MenuSetup] onAppear - sections count = \(sections.count)")
            if sections.isEmpty {
                sections = storeVM.menuSections
            }
        }
        .onChange(of: sections) { _, new in
            storeVM.menuSections = new
            print("[MenuSetup] sections changed -> \(new.count)")
        }
        .onChange(of: editingIndex) { old, new in
            print("[MenuSetup] editingIndex changed:", new == nil ? "nil (closed)" : "open")
        }
        .sheet(item: $editingIndex) { edit in
            AddMenuItemOverlay { newItem in
                sections[edit.sec].items[edit.row] = newItem
                editingIndex = nil
            }
            .interactiveDismissDisabled(false)
            .presentationDetents([.fraction(0.92)])
            .presentationCornerRadius(22)
        }
    }

    // MARK: - Finish Button (extracted to help compiler)
    @ViewBuilder
    private func finishButton() -> some View {
        Button {
            print("[MenuSetup] Finish button tapped (UI). canFinish=\(canFinish), isSubmitting=\(isSubmitting)")

            guard
                let banner = storeVM.bannerImage,
                let icon = storeVM.searchIcon
            else {
                print("[MenuSetup] Missing banner or icon — aborting")
                return
            }

            if isSubmitting {
                print("[MenuSetup] Already submitting — ignoring tap")
                return
            }

            isSubmitting = true

            Task {
                do {
                    print("[MenuSetup] calling registerStore...")
                    try await storeVM.registerStore(
                        storeName: storeVM.storeName,
                        location: storeVM.location,
                        cuisineTypes: storeVM.cuisineTypes,
                        bannerImage: banner,
                        searchIcon: icon,
                        openDays: storeVM.openDays,
                        openingTime: storeVM.openingTime,
                        closingTime: storeVM.closingTime,
                        sections: sections
                    )
                    print("[MenuSetup] registerStore succeeded")

                    print("[MenuSetup] updating onboarding step -> 7")
                    try await authVM.updateOnboardingStep(7)
                    print("[MenuSetup] onboarding step updated (7)")

                    // small delay to ensure Firestore/local session refresh
                    try await Task.sleep(nanoseconds: 300_000_000) // 300ms

                    isSubmitting = false

                    await MainActor.run {
                        print("[MenuSetup] dismissing MenuSetupView")
                        dismiss()
                    }
                } catch {
                    isSubmitting = false
                    print("[MenuSetup] ERROR register/update:", error.localizedDescription)
                }
            }
        } label: {
            Text(isSubmitting ? "Submitting..." : "Finish")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    canFinish ? Color.orange : Color.gray.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .contentShape(Rectangle())
        .allowsHitTesting(true)
        .highPriorityGesture(TapGesture().onEnded { /* presence increases priority */ })
        .disabled(!canFinish || isSubmitting)
        .accessibilityIdentifier("MenuSetup_FinishButton")
    }

    // MARK: - ✅ VALIDATION LOGIC
    private var canFinish: Bool {
        if sections.isEmpty { return false }
        for section in sections {
            if section.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
            if section.items.isEmpty { return false }
            for item in section.items {
                if item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
                if item.price <= 0 { return false }
                if item.prepMinutes <= 0 { return false }
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
                TextField("Enter section name", text: bindingTitle(for: secIdx))
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

    private func bindingTitle(for index: Int) -> Binding<String> {
        Binding(
            get: { sections[index].title },
            set: { sections[index].title = $0 }
        )
    }

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

// MARK: - MenuRow & helpers (unchanged)
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
    NavigationView {
        MenuSetupView()
            .environmentObject(StoreRegistrationViewModel())
    }
}
