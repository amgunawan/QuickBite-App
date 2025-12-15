//
//  ManageMenuTenantView.swift
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

    var body: some View {
        List {

            // ===============================
            // LOADING
            // ===============================
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                }
            }

            // ===============================
            // ERROR
            // ===============================
            else if let error = viewModel.errorMessage {
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

            // ===============================
            // CONTENT
            // ===============================
            else {
                ForEach(viewModel.sections) { section in

                    Section {

                        ForEach(section.items) { item in
                            MenuRow(item: item) {
                                // ✅ FIX: langsung buka edit (tidak perlu tap dua kali)
                                selectedItem = item
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    itemToDelete = item
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
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
        }
        .listStyle(.plain)
        .navigationTitle("Manage Menu & Stock")
        .navigationBarTitleDisplayMode(.inline)

        // ===============================
        // EDIT ITEM
        // ===============================
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

        // ===============================
        // ADD ITEM
        // ===============================
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

        // ===============================
        // DELETE CONFIRMATION
        // ===============================
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
        ref.getData(maxSize: 3 * 1024 * 1024) { data, error in
            if let data = data, let img = UIImage(data: data) {
                self.uiImage = img
            }
        }
    }
}
