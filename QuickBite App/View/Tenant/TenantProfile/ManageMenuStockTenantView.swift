//
//  ManageMenuStockTenantView.swift
//  QuickBite App
//

import SwiftUI
import FirebaseStorage

struct ManageMenuStockTenantView: View {

    @StateObject private var viewModel: TenantMenuViewModel

    // EDIT FLOW
    @State private var selectedItem: MenuItem? = nil

    // ADD FLOW
    @State private var showAddSheet = false
    @State private var pendingCategory: String = ""

    // DELETE FLOW
    @State private var itemToDelete: MenuItem? = nil
    @State private var showDeleteAlert = false

    init(storeId: String) {
        _viewModel = StateObject(
            wrappedValue: TenantMenuViewModel(storeId: storeId)
        )
    }

    // =========================================================
    // MARK: - BODY
    // =========================================================
    var body: some View {
        List {
            contentView
        }
        .listStyle(.plain)
        .navigationTitle("Manage Menu & Stock")
        .navigationBarTitleDisplayMode(.inline)

        // EDIT SHEET
        .sheet(item: $selectedItem) { item in
            EditMenuTenantView(
                item: item,
                viewModel: viewModel
            ) { updated in
                viewModel.updateItem(updated)
                selectedItem = nil
            }
            .presentationDetents([.fraction(0.95)])
            .presentationCornerRadius(22)
        }

        // ADD SHEET
        .sheet(isPresented: $showAddSheet) {
            if viewModel.newItemDraft != nil {
                AddMenuItemOverlay { completedItem in
                    var fixed = completedItem
                    fixed.category = pendingCategory
                    viewModel.saveNewItem(fixed)
                    showAddSheet = false
                }
                .presentationDetents([.fraction(0.95)])
                .presentationCornerRadius(22)
            }
        }

        // DELETE ALERT
        .alert(
            "Delete Menu",
            isPresented: $showDeleteAlert,
            presenting: itemToDelete
        ) { item in
            Button("Delete", role: .destructive) {
                viewModel.deleteItem(item)
            }
            Button("Cancel", role: .cancel) { }
        } message: { item in
            Text("Are you sure you want to delete \"\(item.name)\"?")
        }
    }

    // =========================================================
    // MARK: - CONTENT SWITCH
    // =========================================================
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else {
            menuSections
        }
    }

    // =========================================================
    // MARK: - LOADING
    // =========================================================
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView("Loading...")
            Spacer()
        }
    }

    // =========================================================
    // MARK: - ERROR
    // =========================================================
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 10) {
            Text(error)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)

            Button("Retry") {
                viewModel.refresh()
            }
        }
        .frame(maxWidth: .infinity)
    }

    // =========================================================
    // MARK: - MENU SECTIONS
    // =========================================================
    private var menuSections: some View {
        ForEach(viewModel.sections) { section in
            Section {
                ForEach(section.items) { item in
                    MenuRow(
                        item: item,
                        showStockBadge: true   // ← restore required parameter
                    ) {
                        selectedItem = item
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        deleteButton(for: item)
                    }
                }
            } header: {
                SectionHeader(
                    title: section.title,
                    onAddItem: {
                        pendingCategory = section.title
                        viewModel.addItem(to: section.title)
                        showAddSheet = true
                    }
                )
            }
        }
    }

    // =========================================================
    // MARK: - DELETE BUTTON
    // =========================================================
    private func deleteButton(for item: MenuItem) -> some View {
        Button(role: .destructive) {
            itemToDelete = item
            showDeleteAlert = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

// ======================================================================
// MARK: - SECTION HEADER (UI SAMA)
// ======================================================================
private struct SectionHeader: View {

    let title: String
    let onAddItem: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)

            Spacer()

            Button(action: onAddItem) {
                Text("Add Item")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange, in: Capsule())
            }
        }
        .padding(.vertical, 8)
    }
}

// ======================================================================
// MARK: - ASYNC IMAGE LOADER
// ======================================================================
struct StorageImageView: View {

    let imageURL: String
    @State private var uiImage: UIImage? = nil

    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                ProgressView()
            }
        }
        .onAppear { loadImage() }
        .onChange(of: imageURL) { _, _ in loadImage() }
    }

    private func loadImage() {
        uiImage = nil
        guard !imageURL.isEmpty else { return }

        let ref = Storage.storage().reference(forURL: imageURL)
        ref.getData(maxSize: 3 * 1024 * 1024) { data, _ in
            if let data = data, let img = UIImage(data: data) {
                uiImage = img
            }
        }
    }
}
