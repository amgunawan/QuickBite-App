//
//  MenuOptionsView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

// ==================================================================
// 1. OPTION GROUP VIEW (Sub-Component)
// ==================================================================
struct OptionGroupView: View {
    let category: MenuOptionGroup
    @Binding var selections: [String: Set<MenuOptionChoice>]

    var isMultiSelect: Bool {
        category.maxSelect > 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                Text(category.category)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(isRequirementMet ? .gray : .orange)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))

            // Choices
            VStack(spacing: 0) {
                ForEach(category.choices, id: \.name) { choice in
                    OptionRowView(
                        name: choice.name,
                        price: Double(choice.additionalPrice),
                        isSelected: selections[category.category]?.contains(choice) ?? false,
                        isMultiSelect: isMultiSelect
                    ) {
                        toggle(choice)
                    }
                    .padding(.horizontal)

                    if choice.name != category.choices.last?.name {
                        Divider().padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    var isRequirementMet: Bool {
        let count = selections[category.category]?.count ?? 0
        return count >= category.minSelect
    }

    var subtitle: String {
        if category.maxSelect == 1 { return "Choose 1" }
        if category.minSelect == 0 { return "Optional (Max \(category.maxSelect))" }
        return "Choose \(category.minSelect) - \(category.maxSelect)"
    }

    func toggle(_ choice: MenuOptionChoice) {
        var current = selections[category.category] ?? []

        if current.contains(choice) {
            current.remove(choice)
        } else {
            if category.maxSelect == 1 {
                // Radio: Select only one
                current = [choice]
            } else if current.count < category.maxSelect {
                // Checkbox: Add if under limit
                current.insert(choice)
            }
        }

        selections[category.category] = current
    }
}

// ==================================================================
// 2. MAIN VIEW: MENU OPTIONS VIEW
// ==================================================================
struct MenuOptionsView: View {
    
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    // Restaurant Info
    let restaurantName: String
    let restaurantId: String
    
    // Menu Data
    let item: MenuItem
    let finalPrice: Double
    let originalPrice: Double?
    var itemToEdit: CartItemModel? = nil
    
    @State private var quantity: Int = 1
    @State private var note: String = ""
    @State private var showingNoteSheet = false
    
    // Dynamic State: User Selections
    @State private var selections: [String: Set<MenuOptionChoice>] = [:]
    @State private var showReplaceCartAlert = false
    
    
    // Init Custom
    init(restaurantName: String, restaurantId: String, item: MenuItem, finalPrice: Double, originalPrice: Double?, itemToEdit: CartItemModel? = nil) {
        self.restaurantName = restaurantName
        self.restaurantId = restaurantId
        self.item = item
        self.finalPrice = finalPrice
        self.originalPrice = originalPrice
        self.itemToEdit = itemToEdit
        
        if let editItem = itemToEdit {
            _quantity = State(initialValue: editItem.quantity)
            _note = State(initialValue: editItem.note)
        }
    }
    
    // --- CALCULATIONS ---
    var optionsTotalCost: Double {
        var total: Double = 0
        for (_, choices) in selections {
            for choice in choices {
                total += Double(choice.additionalPrice)
            }
        }
        return total
    }
    
    var totalCalculatedPrice: Double {
        return (finalPrice + optionsTotalCost) * Double(quantity)
    }
    
    // --- VALIDATION ---
    var missingCategories: [String] {
        guard let options = item.options else { return [] }
        var missing: [String] = []
        
        for category in options {
            let selectedCount = selections[category.category]?.count ?? 0
            if selectedCount < category.minSelect {
                missing.append(category.category)
            }
        }
        return missing
    }
    
    var isValid: Bool {
        return missingCategories.isEmpty
    }
    
    // --- BODY ---
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // 1. Header Info
                            MenuItemInfo(
                                imageName: item.imageURL ?? "",
                                name: item.name,
                                salesDescription: item.description ?? "",
                                price: finalPrice,
                                originalPrice: originalPrice,
                                quantity: $quantity
                            )
                            .padding(.horizontal)
                            .padding(.top)
                            .padding(.bottom, 24)
                            
                            // 2. DYNAMIC OPTIONS LOOP (Fixed: Removed duplicate nesting)
                            if let options = item.options {
                                ForEach(options, id: \.category) { category in
                                    OptionGroupView(
                                        category: category,
                                        selections: $selections
                                    )
                                }
                            }
                            
                            Divider().padding(.top, 8)
                            
                            AddNoteView(note: note, action: {
                                showingNoteSheet = true
                            })
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }
                        .padding(.bottom, 140)
                    }
                }
                
                // 3. Bottom Section (Warning & Button)
                VStack(spacing: 0) {
                    
                    // Show Warning if Invalid
                    if !isValid {
                        Text("Please select: \(missingCategories.joined(separator: ", "))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.top, 8)
                            .padding(.bottom, -8)
                            .transition(.opacity)
                    }
                    
                    // Add Button
                    BottomButtonView(
                        price: "Rp\(formatPrice(totalCalculatedPrice))",
                        buttonText: itemToEdit != nil ? "Update Cart" : "Add to Cart",
                        isDisabled: !isValid,
                        action: {
                            checkAndAddToCart()
                        }
                    )
                }
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: -5)
            }
            .navigationTitle(itemToEdit != nil ? "Edit Menu" : "Add Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showingNoteSheet) {
                NoteEntrySheetView(note: $note)
            }
            .alert("Start a new order?", isPresented: $showReplaceCartAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Yes, Clear Cart", role: .destructive) {
                    cart.clearCart() // 1. Hapus cart lama
                    executeAdd()     // 2. Tambah item baru
                }
            } message: {
                Text("Your cart contains items from another restaurant. Starting a new order will clear your current cart.")
            }
            .presentationDetents([.large, .medium])
            .presentationDragIndicator(.visible)
            .background(Color.white)
        }
    }
       
    // --- LOGIC HELPERS ---
    
    func checkAndAddToCart() {
        // Clean IDs for comparison
        let currentCartId = cart.restaurantId.trimmingCharacters(in: .whitespacesAndNewlines)
        let newId = restaurantId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Logic: If cart has items AND IDs differ -> Show Alert
        if !cart.items.isEmpty && currentCartId != newId && !currentCartId.isEmpty {
            showReplaceCartAlert = true
        } else {
            // Safe to add immediately
            executeAdd()
        }
    }
       
    func executeAdd() {
        var finalSelections: [CartOptionSelection] = []

        for (catName, choices) in selections {
            for choice in choices {
                let selection = CartOptionSelection(
                    categoryName: catName,
                    choiceName: choice.name,
                    price: Double(choice.additionalPrice)
                )
                finalSelections.append(selection)
            }
        }

        finalSelections.sort { $0.categoryName < $1.categoryName }

        let resolvedId: UUID = itemToEdit?.id ?? UUID()
        let resolvedImage: String = item.imageURL ?? ""
        let resolvedPrepTime: Int = item.prepTimeMinutes ?? 0

        let newItem = CartItemModel(
            id: resolvedId,
            menuItemId: item.id,
            name: item.name,
            imageName: resolvedImage,
            basePrice: finalPrice,
            baseOriginalPrice: originalPrice,
            prepTime: resolvedPrepTime,
            quantity: quantity,
            note: note,
            selectedOptions: finalSelections
        )

        if itemToEdit != nil {
            cart.updateItem(newItem)
        } else {
            cart.add(
                item: newItem,
                restaurantName: restaurantName,
                restaurantId: restaurantId
            )
        }

        dismiss()
    }
}

// ==================================================================
// --- SUB-VIEWS ---
// ==================================================================

struct OptionRowView: View {
    let name: String
    let price: Double
    let isSelected: Bool
    let isMultiSelect: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(name).font(.system(size: 16))
                    if price > 0 {
                        Text("+Rp\(formatPrice(price))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 1)
                    }
                }
                Spacer()
                
                Image(systemName: isMultiSelect ? (isSelected ? "checkmark.square.fill" : "square") : (isSelected ? "record.circle" : "circle"))
                    .font(.system(size: 19))
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct BottomButtonView: View {
    let price: String
    let buttonText: String
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(buttonText) - \(price)")
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isDisabled ? Color.gray : Color.orange)
                .cornerRadius(24)
        }
        .disabled(isDisabled)
        .padding()
    }
}

struct MenuItemInfo: View {
    let imageName: String
    let name: String
    let salesDescription: String
    let price: Double
    let originalPrice: Double?
    @Binding var quantity: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let url = URL(string: imageName), imageName.starts(with: "http") {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 64, height: 64).cornerRadius(8).clipped()
            } else {
                Image(imageName).resizable().scaledToFill()
                    .frame(width: 64, height: 64).cornerRadius(8).clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.system(size: 17, weight: .semibold)).lineLimit(2)
                Text(salesDescription).font(.system(size: 14)).foregroundColor(.gray).lineLimit(2)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("Rp\(formatPrice(price))").font(.system(size: 18, weight: .bold)).foregroundColor(.orange)
                    if let original = originalPrice {
                        Text("Rp\(formatPrice(original))").font(.system(size: 14)).foregroundColor(.gray).strikethrough()
                    }
                }
            }
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                    Image(systemName: "minus").font(.system(size: 14, weight: .bold)).foregroundColor(quantity > 1 ? .orange : .gray)
                }
                Text("\(quantity)").font(.system(size: 16, weight: .bold)).frame(minWidth: 20)
                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.white).cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }
}

struct AddNoteView: View {
    let note: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "list.clipboard").font(.system(size:16))
                HStack {
                    Text(note.isEmpty ? "Note for Restaurant" : note)
                        .font(.system(size: 14))
                        .foregroundColor(note.isEmpty ? .gray : .primary)
                        .lineLimit(1)
                }
            }
        }.buttonStyle(.plain)
    }
}

struct NoteEntrySheetView: View {
    @Binding var note: String
    @State private var tempNote: String
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    init(note: Binding<String>) {
        self._note = note
        self._tempNote = State(initialValue: note.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("Add Notes").font(.system(size: 18, weight: .semibold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).foregroundColor(.black).padding(8).background(Color(.systemGray6)).clipShape(Circle())
                }
            }
            HStack {
                TextField("e.g. no onions, extra soy sauce...", text: $tempNote).focused($isTextFieldFocused)
                if !tempNote.isEmpty {
                    Button(action: { tempNote = "" }) { Image(systemName: "xmark.circle.fill") }
                }
            }
            .padding().background(Color.white).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            Button(action: { note = tempNote; dismiss() }) {
                Text("Confirm").fontWeight(.medium).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 12).background(Color.orange).cornerRadius(24)
            }
            Spacer()
        }
        .padding().onAppear { isTextFieldFocused = true }
        .presentationDetents([.medium]).presentationDragIndicator(.hidden).background(Color.white)
    }
}

// MARK: - PREVIEW
struct MenuOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyItem = MenuItem(
            itemId: "1",
            name: "Ramen Preview",
            description: "Desc",
            price: 35000,
            category: "Ramen",
            imageURL: nil,
            defaultStock: nil,
            prepTimeMinutes: 10,
            options: [
                MenuOptionGroup(
                    category: "Noodle Type",
                    minSelect: 1,
                    maxSelect: 1,
                    choices: [
                        MenuOptionChoice(name: "Thick", additionalPrice: 0),
                        MenuOptionChoice(name: "Thin", additionalPrice: 0)
                    ]
                )
            ]
        )
        
        MenuOptionsView(
            restaurantName: "Raburi",
            restaurantId: "123",
            item: dummyItem,
            finalPrice: 30000,
            originalPrice: 35000
        ).environmentObject(CartViewModel())
    }
}
