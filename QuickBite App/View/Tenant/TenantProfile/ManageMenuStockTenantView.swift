//
//  ManageMenuTenantView.swift
//  QuickBite App
//

import SwiftUI
import FirebaseStorage

struct ManageMenuStockTenantView: View {
    
    @StateObject private var viewModel: TenantMenuViewModel
    
    @State private var selectedItem: MenuItem? = nil
    @State private var showEditSheet = false
    @State private var showAddSheet = false     // 👉 Sheet untuk Add Item
    
    // storeId di-pass dari parent page
    init(storeId: String) {
        _viewModel = StateObject(wrappedValue: TenantMenuViewModel(storeId: storeId))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            }
            
            else if let error = viewModel.errorMessage {
                VStack(spacing: 10) {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        viewModel.refresh()
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            
            else {
                VStack(spacing: 16) {
                    ForEach(viewModel.sections) { section in
                        SectionCard(
                            title: section.title,
                            onAddItem: {
                                viewModel.addItem(to: section.title)   // Insert placeholder
                                showAddSheet = true                    // Open AddOverlay
                            }
                        ) {
                            VStack(spacing: 12) {
                                ForEach(section.items) { item in
                                    MenuRow(item: item) {
                                        selectedItem = item
                                        showEditSheet = true
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .navigationTitle("Manage Menu & Stock")
        .navigationBarTitleDisplayMode(.inline)
        
        // ===================================================
        // SHEET: EDIT ITEM
        // ===================================================
        .sheet(isPresented: $showEditSheet) {
            if let item = selectedItem {
                EditMenuTenantView(item: item, viewModel: viewModel) { updated in
                    viewModel.updateItem(updated)
                    showEditSheet = false
                }
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(22)
            }
        }
        
        // ===================================================
        // SHEET: ADD NEW ITEM (after pressing Add Item)
        // ===================================================
        .sheet(isPresented: $showAddSheet) {
            if let draft = viewModel.newItemDraft {
                AddMenuItemOverlay(onSave: { completedItem in
                    viewModel.saveNewItem(completedItem)
                    showAddSheet = false
                })
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(22)
            }
        }
    }
}

// ======================================================================
// MARK: - SECTION CARD
// ======================================================================

private struct SectionCard<Content: View>: View {
    
    let title: String
    let onAddItem: () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 12) {
            
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
            .padding(.horizontal)
            
            Divider()
                .overlay(Color.orange.opacity(0.25))
                .padding(.horizontal)
            
            content
                .padding(.horizontal)
        }
    }
}

// ======================================================================
// MARK: - MENU ROW
// ======================================================================

private struct MenuRow: View {
    
    let item: MenuItem
    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            StorageImageView(imageURL: item.imageURL)
                .frame(width: 78, height: 78)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(item.name.isEmpty ? "New Item" : item.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                
                StatusBadge(status: item.stockStatus)
                
                Text("Rp\(formatPrice(Double(item.price)))")
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

// ======================================================================
// MARK: - STATUS BADGE
// ======================================================================

private struct StatusBadge: View {
    
    let status: StockStatus
    
    var body: some View {
        let colors: (Color, Color) = {
            switch status {
            case .inStock: return (.white, .green)
            case .lowStock: return (.black, .yellow.opacity(0.95))
            case .outOfStock: return (.white, .red)
            }
        }()
        
        return Text(status.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundColor(colors.0)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colors.1, in: Capsule())
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

#Preview {
    NavigationStack {
        ManageMenuStockTenantView(storeId: "2plb4UCwxjle2Yy6PTdj")
    }
}
