//
//  MenuOptionsView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

// ==================================================================
// --- 1. MAIN VIEW (Tampilan Overlay / Sheet) ---
// ==================================================================
struct MenuOptionsView: View {
    
    // Properti untuk menutup sheet
    @Environment(\.dismiss) var dismiss
    
    // Properti untuk menerima data item
    let imageName: String
    let name: String
    let salesDescription: String
    let priceString: String
    let originalPriceString: String?
    
    // State untuk mengelola pilihan
    @State private var quantity: Int = 1
    
    // State untuk menyimpan catatan
    @State private var note: String = ""
    
    // State untuk memunculkan sheet catatan
    @State private var showingNoteSheet = false
    
    // Pilihan Noodle Type (Choose 1)
    @State private var selectedNoodleType: String = "Thick"
    let noodleTypes = ["Thick", "Thin"]
    
    // Pilihan Level (Choose 1)
    @State private var selectedLevel: String = "Sleeping (Lvl. 0)"
    let levels = [
        ("Sleeping (Lvl. 0)", 0.0),
        ("Angry (Lvl. 5)", 1550.0),
        ("Crazy (Lvl. 10)", 3100.0)
    ]
    
    // Pilihan Topping (Choose 1)
    @State private var selectedTopping: String = "Classic"
    let toppings = ["Classic", "Chicken Chashu"]
    
    // --- (FUNGSI KALKULASI HARGA - CONTOH) ---
    private var calculatedPrice: String {
        var total = Double(priceString.replacingOccurrences(of: "Rp", with: "").replacingOccurrences(of: ".", with: "")) ?? 0
        if let levelPrice = levels.first(where: { $0.0 == selectedLevel })?.1 {
            total += levelPrice
        }
        total *= Double(quantity)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formattedPrice = formatter.string(from: NSNumber(value: total)) ?? "\(total)"
        return "Rp\(formattedPrice)"
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    // --- 2. Konten Pilihan (Bisa di-scroll) ---
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // --- Info Item & Stepper ---
                            MenuItemInfo(
                                imageName: imageName,
                                name: name,
                                salesDescription: salesDescription,
                                priceString: priceString,
                                originalPriceString: originalPriceString,
                                quantity: $quantity
                            )
                            .padding(.horizontal)
                            .padding(.top) // Padding atas untuk jarak dari Nav Bar
                            .padding(.bottom, 24) // Jarak ke section pertama
                            
                            // --- Pilihan Noodle Type ---
                            OptionSectionView(
                                title: "Noodle Type",
                                subtitle: "Choose 1",
                                selection: $selectedNoodleType,
                                options: noodleTypes.map { ($0, 0.0) }
                            )
                            
                            // --- Pilihan Level ---
                            OptionSectionView(
                                title: "Level",
                                subtitle: "Choose 1",
                                selection: $selectedLevel,
                                options: levels
                            )
                            
                            // --- Pilihan Topping ---
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
                            .padding(.top, 12) // Jarak dari section terakhir
                            
                        }
                        .padding(.bottom, 100) // Beri ruang untuk tombol sticky
                    }
                }
                
                // --- 3. Tombol "Add to Cart" (Sticky) ---
                BottomButtonView(price: calculatedPrice, action: {
                    // Aksi add to cart...
                    print("Added to cart: \(name) x\(quantity)")
                    print("Noodle: \(selectedNoodleType), Level: \(selectedLevel), Topping: \(selectedTopping)")
                    print("Note: \(note)") // <-- Menambahkan note ke output
                    dismiss() // Tutup sheet
                })
                
            }
            .navigationTitle("Add Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        dismiss() // Tutup tanpa menyimpan
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(8)
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

// --- Info Item & Stepper Kuantitas ---
struct MenuItemInfo: View {
    let imageName: String
    let name: String
    let salesDescription: String
    let priceString: String
    let originalPriceString: String?
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
                    Text(priceString)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                    if let original = originalPriceString {
                        Text(original)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    if quantity > 1 { quantity -= 1 }
                }) {
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

// --- Grup Pilihan (misal: "Noodle Type") ---
struct OptionSectionView: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let options: [(name: String, price: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            
            // Daftar Pilihan
            VStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.element.name) { index, option in
                    OptionRowView(
                        name: option.name,
                        price: option.price,
                        isSelected: self.selection == option.name,
                        action: {
                            self.selection = option.name
                        }
                    )
                    .padding(.horizontal)
                    
                    if index < options.count - 1 {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

//
struct AddNoteView: View {
    let note: String
    let action: () -> Void // Aksi untuk membuka sheet
    
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

// --- Baris Pilihan (misal: "Thick") ---
struct OptionRowView: View {
    // ... (Tidak ada perubahan di sini) ...
    let name: String
    let price: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(size: 16))
                    
                    if price > 0 {
                        Text("+Rp\(String(format: "%.0f", price).replacingOccurrences(of: ".", with: ","))")
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

// Struct baru untuk sheet entri catatan
struct NoteEntrySheetView: View {
    @Binding var note: String // Binding ke note asli
    @State private var tempNote: String // State lokal untuk diedit
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool // Untuk keyboard otomatis

    // Inisialisasi tempNote dengan nilai dari note asli
    init(note: Binding<String>) {
        self._note = note
        self._tempNote = State(initialValue: note.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 20) {
            // 1. Header ("Add Notes" dan "X")
            HStack {
                Spacer() 
                Text("Add Notes")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            
            // 2. TextField
            HStack {
                TextField("e.g. no onions, extra soy sauce...", text: $tempNote)
                    .focused($isTextFieldFocused) // Fokus otomatis
                
                // Tombol "Clear"
                if !tempNote.isEmpty {
                    Button(action: { tempNote = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )

            // 3. Tombol "Confirm"
            Button(action: {
                note = tempNote
                dismiss()
            }) {
                Text("Confirm")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            isTextFieldFocused = true // Tampilkan keyboard saat muncul
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .background(Color.white)
    }
}


// --- Tombol "Add to Cart" di Bawah ---
struct BottomButtonView: View {
    let price: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Add to Cart - \(price)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
    }
}


// ==================================================================
// --- 3. PREVIEW ---
// ==================================================================
struct MenuOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MenuOptionsView(
            imageName: "ChickenKatsuShirokaraRamen",
            name: "Chicken Katsu Shirokara Ramen",
            salesDescription: "10 terjual",
            priceString: "Rp30.000",
            originalPriceString: "Rp35.000"
        )
    }
}
