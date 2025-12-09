//
//  MenuOptionsView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct MenuOptionsView: View {
    
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    // Info Restoran (Penting untuk Cart)
    let restaurantName: String
    let restaurantId: String
    
    // Data Menu
    let item: MenuItemModel
    let finalPrice: Double
    let originalPrice: Double?
    var itemToEdit: CartItemModel? = nil
    
    @State private var quantity: Int = 1
    @State private var note: String = ""
    @State private var showingNoteSheet = false
    
    // Dynamic State: Menyimpan pilihan user
    @State private var selections: [String: Set<MenuOptionChoice>] = [:]
    
    // Init Custom
    init(restaurantName: String, restaurantId: String, item: MenuItemModel, finalPrice: Double, originalPrice: Double?, itemToEdit: CartItemModel? = nil) {
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
                total += Double(choice.price)
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
                            
                            // 2. DYNAMIC OPTIONS LOOP
                            if let options = item.options {
                                ForEach(options, id: \.category) { category in
                                    
                                    // Tentukan apakah ini Checkbox atau Radio
                                    let isMultiSelect = category.maxSelect > 1
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Section Header
                                        HStack {
                                            Text(category.category)
                                                .font(.system(size: 16, weight: .semibold))
                                            Spacer()
                                            
                                            // Helper Text
                                            let subtitle = getSubtitle(min: category.minSelect, max: category.maxSelect)
                                            Text(subtitle)
                                                .font(.system(size: 14))
                                                .foregroundColor(isRequirementMet(category: category) ? .gray : .orange)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        
                                        // Choices Loop
                                        VStack(spacing: 0) {
                                            ForEach(category.choices, id: \.name) { choice in
                                                OptionRowView(
                                                    name: choice.name,
                                                    price: Double(choice.price),
                                                    isSelected: isSelected(category: category.category, choice: choice),
                                                    isMultiSelect: isMultiSelect, // Kirim tipe seleksi
                                                    action: {
                                                        toggleSelection(category: category, choice: choice)
                                                    }
                                                )
                                                .padding(.horizontal)
                                                
                                                if choice.name != category.choices.last?.name {
                                                    Divider().padding(.horizontal)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Divider().padding(.top, 8)
                            
                            AddNoteView(note: note, action: {
                                showingNoteSheet = true
                            })
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }
                        .padding(.bottom, 140) // Padding bawah agar tidak tertutup tombol
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
                        isDisabled: !isValid, // Tombol mati jika tidak valid
                        action: {
                            addToCart()
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
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
        .background(Color.white)
    }
    
    // --- LOGIC HELPERS ---
    
    func isRequirementMet(category: MenuOptionCategory) -> Bool {
        let count = selections[category.category]?.count ?? 0
        return count >= category.minSelect
    }
    
    func getSubtitle(min: Int, max: Int) -> String {
        if max == 1 { return "Choose 1" }
        if min == 0 { return "Optional (Max \(max))" }
        return "Choose \(min) - \(max)"
    }
    
    func isSelected(category: String, choice: MenuOptionChoice) -> Bool {
        return selections[category]?.contains(choice) ?? false
    }
    
    func toggleSelection(category: MenuOptionCategory, choice: MenuOptionChoice) {
        var currentSet = selections[category.category] ?? []
        
        if currentSet.contains(choice) {
            currentSet.remove(choice)
        } else {
            if category.maxSelect == 1 {
                // Radio: Reset yang lain, pilih ini
                currentSet = [choice]
            } else {
                // Checkbox: Cek limit max
                if currentSet.count < category.maxSelect {
                    currentSet.insert(choice)
                }
            }
        }
        selections[category.category] = currentSet
    }
    
    func addToCart() {
        var finalSelections: [CartOptionSelection] = []
        for (catName, choices) in selections {
            for choice in choices {
                finalSelections.append(CartOptionSelection(
                    categoryName: catName,
                    choiceName: choice.name,
                    price: Double(choice.price)
                ))
            }
        }
        finalSelections.sort { $0.categoryName < $1.categoryName }
        
        let newItem = CartItemModel(
            id: itemToEdit?.id ?? UUID(),
            menuItemId: item.id, // Mengambil ID asli dari MenuItemModel
            name: item.name,
            imageName: item.imageURL ?? "",
            basePrice: finalPrice,
            baseOriginalPrice: originalPrice,
            prepTime: item.prepTime,
            quantity: quantity,
            note: note,
            selectedOptions: finalSelections
        )
        
        if itemToEdit != nil {
            cart.updateItem(newItem)
        } else {
            cart.add(item: newItem, restaurantName: restaurantName, restaurantId: restaurantId)
        }
        dismiss()
    }
}

// ==================================================================
// --- SUB-VIEWS ---
// ==================================================================

// 1. OPTION ROW VIEW (Updated with isMultiSelect)
struct OptionRowView: View {
    let name: String
    let price: Double
    let isSelected: Bool
    let isMultiSelect: Bool // Parameter Baru
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
                
                // Icon Logic: Square (Checkbox) vs Circle (Radio)
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

// 2. BOTTOM BUTTON VIEW (Updated with isDisabled)
struct BottomButtonView: View {
    let price: String
    let buttonText: String
    let isDisabled: Bool // Parameter Baru
    let action: () -> Void
    
    // Init default agar fleksibel
    init(price: String, buttonText: String = "Add to Cart", isDisabled: Bool = false, action: @escaping () -> Void) {
        self.price = price
        self.buttonText = buttonText
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text("\(buttonText) - \(price)")
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                // Warna berubah jadi abu-abu jika disabled
                .background(isDisabled ? Color.gray : Color.orange)
                .cornerRadius(24)
        }
        .disabled(isDisabled) // Matikan interaksi
        .padding()
        // Background putih dihapus di sini agar tidak menumpuk,
        // ditangani oleh VStack di parent
    }
}

// 3. MENU ITEM INFO (Tidak berubah, hanya pelengkap)
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

// 4. ADD NOTE VIEW (Tidak berubah)
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

// 5. NOTE ENTRY SHEET (Tidak berubah)
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
        let dummyItem = MenuItemModel(
            id: "1",
            name: "Ramen Preview",
            description: "Desc",
            price: 35000,
            category: "Ramen",
            imageURL: nil,
            options: [
                MenuOptionCategory(
                    id: UUID(),
                    category: "Noodle Type",
                    minSelect: 1,
                    maxSelect: 1,
                    choices: [
                        MenuOptionChoice(name: "Thick", price: 0),
                        MenuOptionChoice(name: "Thin", price: 0)
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
