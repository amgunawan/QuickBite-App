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

    // MARK: - Menu Data
    @State private var sections: [MenuSectionModel] = []

    // MARK: - UI States
    @State private var editingIndex: EditingItem? = nil
    @State private var isSubmitting = false

    struct EditingItem: Identifiable, Equatable {
        let id = UUID()
        let sec: Int
        let row: Int
    }

    var body: some View {
        mainContent
            .overlay(editSheet)
            .onAppear(perform: onAppear)
            .onChange(of: sections, perform: onSectionsChange)
            .onChange(of: editingIndex, perform: onEditingChange)
    }

    // MARK: - MAIN CONTENT
    private var mainContent: some View {
        VStack(spacing: 0) {
            MenuHeader(
                step: 2,
                title: "Build your Quickbite Store",
                subtitle: "Configure your store’s menu and branding"
            )
            .padding(.bottom, 8)

            menuScrollView
            Spacer(minLength: 8)
            finishButton()
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
    }

    // MARK: - SCROLL VIEW
    private var menuScrollView: some View {
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
                    addSectionButton
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.55)
    }

    // MARK: - ADD SECTION BUTTON
    private var addSectionButton: some View {
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

    // MARK: - EDIT SHEET
    private var editSheet: some View {
        EmptyView()
            .sheet(item: $editingIndex) { edit in
                let existing = sections[edit.sec].items[edit.row]
                let category = sections[edit.sec].title

                AddMenuItemOverlay(existingItem: existing, category: category) { saved in
                    sections[edit.sec].items[edit.row] = saved
                    editingIndex = nil
                }
                .interactiveDismissDisabled(false)
                .presentationDetents([.fraction(0.92)])
                .presentationCornerRadius(22)
            }
    }

    // MARK: - FINISH BUTTON
    @ViewBuilder
    private func finishButton() -> some View {
        Button {
            handleFinishTap()
        } label: {
            Text(isSubmitting ? "Submitting..." : "Finish")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    canFinish ? Color.orange : Color.gray.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 100)
                )
        }
        .disabled(!canFinish || isSubmitting)
        .accessibilityIdentifier("MenuSetup_FinishButton")
    }

    // MARK: - FINISH LOGIC
    // MARK: - FINISH LOGIC
    private func handleFinishTap() {
        guard
            let banner = storeVM.bannerImage,
            let icon = storeVM.searchIcon,
            !isSubmitting
        else { return }

        isSubmitting = true

        Task {
            do {
                let storeID = try await storeVM.registerStore(
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

                try await authVM.finalizeMerchantOnboarding(storeId: storeID)

                await MainActor.run {
                    isSubmitting = false
                    storeVM.clearDraft()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                }
                print("[MenuSetup] ERROR:", error.localizedDescription)
            }
        }
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
                MenuRow(item: section.items[rowIdx], showStockBadge: false) {
                    editingIndex = EditingItem(sec: secIdx, row: rowIdx)
                }
            }
        }
    }

    // MARK: - BINDINGS & HELPERS
    private func bindingTitle(for index: Int) -> Binding<String> {
        Binding(
            get: { sections[index].title },
            set: { sections[index].title = $0 }
        )
    }

    private func addItem(in secIdx: Int) {
        let newItem = MenuItem(
            itemId: "ITEM_\(UUID().uuidString.prefix(6))",
            name: "",
            description: "",
            price: 0,
            category: sections[secIdx].title,
            imageURL: "",
            defaultStock: 10,
            prepTimeMinutes: 0,
            options: [],
            currentStock: 10
        )
        sections[secIdx].items.insert(newItem, at: 0)
    }

    // MARK: - VALIDATION
    private var canFinish: Bool {
        guard !sections.isEmpty else { return false }

        for section in sections {
            if section.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
            if section.items.isEmpty {
                return false
            }
            for item in section.items where !isValid(item) {
                return false
            }
        }
        return true
    }

    private func isValid(_ item: MenuItem) -> Bool {
        !item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        item.price > 0 &&
        (item.prepTimeMinutes ?? 0) > 0
    }

    // MARK: - EMPTY STATE
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
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.orange, in: Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4))
        )
    }

    // MARK: - LIFECYCLE HANDLERS
    private func onAppear() {
        if sections.isEmpty {
            sections = storeVM.menuSections
        }
    }

    private func onSectionsChange(_ new: [MenuSectionModel]) {
        storeVM.menuSections = new
    }

    private func onEditingChange(_ new: EditingItem?) {
        print("[MenuSetup] editingIndex:", new == nil ? "closed" : "open")
    }
}

#Preview {
    NavigationView {
        MenuSetupView()
            .environmentObject(StoreRegistrationViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
