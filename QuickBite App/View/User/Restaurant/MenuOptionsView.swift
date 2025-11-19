//
//  MenuOptionsView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct MenuOptionsView: View {
    
    // DIPERBARUI: Dapatkan CartViewModel dari Environment
    @EnvironmentObject var cart: CartViewModel
    
    @Environment(\.dismiss) var dismiss
    
    let imageName: String
    let name: String
    let salesDescription: String
    let price: Double
    let originalPrice: Double?
    
    var itemToEdit: CartItem? = nil
    
    @State private var quantity: Int = 1
    @State private var note: String = ""
    @State private var showingNoteSheet = false
    
    @State private var selectedNoodleType: String = "Thick"
    let noodleTypes = ["Thick", "Thin"]
    
    @State private var selectedLevel: String = "Sleeping (Lvl. 0)"
    let levels = [
        ("Sleeping (Lvl. 0)", 0.0),
        ("Angry (Lvl. 5)", 1550.0),
        ("Crazy (Lvl. 10)", 3100.0)
    ]
    
    @State private var selectedTopping: String = "Classic"
    let toppings = ["Classic", "Chicken Chashu"]
    
    
    init(imageName: String, name: String, salesDescription: String, price: Double, originalPrice: Double?, itemToEdit: CartItem? = nil) {
        self.imageName = imageName
        self.name = name
        self.salesDescription = salesDescription
        self.price = price
        self.originalPrice = originalPrice
        self.itemToEdit = itemToEdit
        
        // Jika mode edit, isi state awal dengan data dari itemToEdit
        if let item = itemToEdit {
            _quantity = State(initialValue: item.quantity)
            _note = State(initialValue: item.note)
            _selectedNoodleType = State(initialValue: item.noodleType)
            _selectedLevel = State(initialValue: item.level)
            _selectedTopping = State(initialValue: item.topping)
        }
    }
    
    
    // --- KALKULASI HARGA (Updated to Double) ---
    private var currentOptionsPrice: Double {
        var total: Double = 0
        if let levelPrice = levels.first(where: { $0.0 == selectedLevel })?.1 {
            total += levelPrice
        }
        
        return total
    }
    
    private var totalCalculatedPrice: Double {
        (price + currentOptionsPrice) * Double(quantity)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            MenuItemInfo(
                                imageName: imageName,
                                name: name,
                                salesDescription: salesDescription,
                                price: price,
                                originalPrice: originalPrice,
                                quantity: $quantity
                            )
                            .padding(.horizontal)
                            .padding(.top)
                            .padding(.bottom, 24)
                            
                            OptionSectionView(
                                title: "Noodle Type",
                                subtitle: "Choose 1",
                                selection: $selectedNoodleType,
                                options: noodleTypes.map { ($0, 0.0) }
                            )
                            
                            OptionSectionView(
                                title: "Level",
                                subtitle: "Choose 1",
                                selection: $selectedLevel,
                                options: levels
                            )
                            
                            OptionSectionView(
                                title: "Topping",
                                subtitle: "Choose 1",
                                selection: $selectedTopping,
                                options: toppings.map { ($0, 0.0) }
                            )
                            
                            Divider()
                                .padding(.top, 8)
                            
                            AddNoteView(note: note, action: {
                                showingNoteSheet = true
                            })
                            .padding(.horizontal)
                            .padding(.top, 12)
                            
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                // Tombol Add to Cart
                BottomButtonView(
                    price: "Rp\(formatPrice(totalCalculatedPrice))",
                    buttonText: itemToEdit != nil ? "Update Cart" : "Add to Cart",
                    action: {
                        let newItem = CartItem(
                            id: itemToEdit?.id ?? UUID(),
                            name: name,
                            imageName: imageName,
                            basePrice: price,
                            baseOriginalPrice: originalPrice,
                            optionsPrice: currentOptionsPrice,
                            noodleType: selectedNoodleType,
                            level: selectedLevel,
                            topping: selectedTopping,
                            note: note,
                            quantity: quantity
                        )
                        
                        if itemToEdit != nil {
                            // Mode Edit: Update item yang ada
                            cart.updateItem(newItem)
                        } else {
                            // Mode Add: Tambah baru
                            cart.add(item: newItem)
                        }
                        
                        dismiss()
                    }
                )
                
            }
            .navigationTitle(itemToEdit != nil ? "Edit Menu" : "Add Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .clipShape(Circle())
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
}

// ==================================================================
// --- 2. SUB-VIEWS (Komponen UI internal) ---
// ==================================================================

struct MenuItemInfo: View {
    let imageName: String
    let name: String
    let salesDescription: String
    let price: Double
    let originalPrice: Double?
    @Binding var quantity: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 17, weight: .semibold))
                Text(salesDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                HStack(alignment: .bottom, spacing: 4) {
                    // Format Price
                    Text("Rp\(formatPrice(price))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                    if let original = originalPrice {
                        Text("Rp\(formatPrice(original))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(quantity > 1 ? .orange : .gray)
                }
                
                Text("\(quantity)")
                    .font(.system(size: 16, weight: .bold))
                    .frame(minWidth: 20)
                
                Button(action: { quantity += 1 }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

struct OptionSectionView: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let options: [(name: String, price: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title).font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(subtitle).font(.system(size: 14)).foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            
            VStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.element.name) { index, option in
                    OptionRowView(
                        name: option.name,
                        price: option.price,
                        isSelected: self.selection == option.name,
                        action: { self.selection = option.name }
                    )
                    .padding(.horizontal)
                    
                    if index < options.count - 1 {
                        Divider().padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct AddNoteView: View {
    let note: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "list.clipboard")
                    .font(.system(size:16))
                
                HStack {
                    Text(note.isEmpty ? "Note for Restaurant" : note)
                        .font(.system(size: 14))
                        .foregroundColor(note.isEmpty ? .gray : .primary)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct OptionRowView: View {
    let name: String
    let price: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(name).font(.system(size: 16))
                    if price > 0 {
                        // Format Price
                        Text("+Rp\(formatPrice(price))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 1)
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "record.circle" : "circle")
                    .font(.system(size: 19))
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                TextField("e.g. no onions, extra soy sauce...", text: $tempNote)
                    .focused($isTextFieldFocused)
                if !tempNote.isEmpty {
                    Button(action: { tempNote = "" }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            Button(action: {
                note = tempNote
                dismiss()
            }) {
                Text("Confirm").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.orange).cornerRadius(50)
            }
            Spacer()
        }
        .padding()
        .onAppear { isTextFieldFocused = true }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .background(Color.white)
    }
}

struct BottomButtonView: View {
    let price: String
    // DIPERBARUI: Text tombol dinamis
    let buttonText: String
    let action: () -> Void
    
    // Init default agar tidak error di tempat lain
    init(price: String, buttonText: String = "Add to Cart", action: @escaping () -> Void) {
        self.price = price
        self.buttonText = buttonText
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            // Gunakan buttonText
            Text("\(buttonText) - \(price)").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.orange).cornerRadius(50)
        }.padding().background(Color.white)

    }
}

struct MenuOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MenuOptionsView(
            imageName: "ChickenKatsuShirokaraRamen",
            name: "Chicken Katsu Shirokara Ramen",
            salesDescription: "10 terjual",
            price: 30000,
            originalPrice: 35000
        ).environmentObject(CartViewModel())
    }
}
