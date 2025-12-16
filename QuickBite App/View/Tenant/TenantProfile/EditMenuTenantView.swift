//
//  EditMenuTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 10/11/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct EditMenuTenantView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TenantMenuViewModel
    
    @State var item: MenuItem
    var onSave: (MenuItem) -> Void
    
    @State private var prepMinutes: Int = 10

    private let minuteChoices = Array(stride(from: 5, through: 120, by: 5))
    
    @State private var optionGroups: [MenuOptionGroup]
    
    // image picking
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var localImage: UIImage? = nil
    @State private var fileName: String = "No file chosen"
    
    init(item: MenuItem, viewModel: TenantMenuViewModel, onSave: @escaping (MenuItem) -> Void) {
        self._item = State(initialValue: item)
        self._optionGroups = State(initialValue: item.options ?? [])
        self._prepMinutes = State(initialValue: item.prepTimeMinutes ?? 10)
        self.viewModel = viewModel
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        imageSection
                        Divider()
                        
                        infoSection
                        Divider()
                        
                        customizationSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                saveButton
            }
            .navigationTitle("Edit Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.95)])
        .presentationCornerRadius(22)
        .background(Color.white)
    }
}

extension EditMenuTenantView {
    
    // ========================================================
    // MARK: - IMAGE SECTION (STYLE MATCH AddMenuItemOverlay)
    // ========================================================
    
    var imageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Item Image")
                .font(.system(size: 17, weight: .semibold))
            
            HStack(alignment: .top, spacing: 14) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                    
                    if let img = localImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 98, height: 98)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        StorageImageView(imageURL: item.imageURL ?? "")
                            .frame(width: 98, height: 98)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .frame(width: 98, height: 98)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    // MATCH AddMenuItemOverlay BUTTON
                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        Text("Choose File")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.orange.opacity(0.15)))
                    }
                    
                    
                    
                    Text("A clear, square image looks best")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .onChange(of: pickedPhoto) { _, _ in
            Task { await uploadPickedImage() }
        }
    }
    
    // Upload Image to Firebase
    private func uploadPickedImage() async {
        guard let pickedPhoto else { return }
        
        do {
            if let data = try await pickedPhoto.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                self.localImage = img
                self.fileName = pickedPhoto.itemIdentifier ?? "image.jpg"
                
                let filename = "IMG-\(UUID().uuidString.prefix(6)).jpg"
                
                viewModel.uploadImage(
                    data,
                    filename: filename,
                    category: item.category ?? ""
                ) { url in
                    if let url = url {
                        DispatchQueue.main.async {
                            self.item.imageURL = "\(url)?v=\(UUID().uuidString)"
                        }
                    }
                }
            }
        } catch {
            print("Error:", error)
        }
    }
    
    
    // ========================================================
    // MARK: - ITEM INFORMATION SECTION
    // ========================================================
    
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            Text("Item Information")
                .font(.system(size: 17, weight: .semibold))
            
            field(title: "Name", text: $item.name)
            VStack(alignment: .leading, spacing: 6) {
                Text("Short Description")
                    .font(.caption)

                ZStack(alignment: .bottomTrailing) {
                    TextEditor(
                        text: Binding(
                            get: { item.description ?? "" },
                            set: { newValue in
                                let words = newValue.wordCount
                                if words <= 100 {
                                    item.description = newValue
                                }
                            }
                        )
                    )
                    .frame(minHeight: 80)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3))
                    )

                    Text("\((item.description ?? "").wordCount) / 100 words")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 12)
                        .padding(.bottom, 8)
                }
            }


            HStack(spacing: 12) {
                fieldNumber(title: "Base Price (Rp)", value: $item.price)
                // STOCK
                VStack(alignment: .leading, spacing: 6) {
                    Text("Stock / Day").font(.caption)
                    
                    TextField("0", value: $item.currentStock, formatter: NumberFormatter.decimalNoGrouping)
                        .keyboardType(.numberPad)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                // PREP TIME (Picker)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prep Time (Max)")
                        .font(.caption)

                    HStack(spacing: 1) {
                        Picker("", selection: $prepMinutes) {
                            ForEach(minuteChoices, id: \.self) { m in
                                Text("\(m)").tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.orange)
//                        .frame(width: 60)
//                        .clipped()

                        Text("mins")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(width: 153, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3))
                    )
                }
                .onChange(of: prepMinutes) { _, newValue in
                    item.prepTimeMinutes = newValue
                }

                
            }
        }
    }
    
    private func field(title: String, text: Binding<String>, multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption)
            
            if multiline {
                TextEditor(text: text)
                    .frame(minHeight: 80)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
            } else {
                TextField("", text: text)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
            }
        }
    }
    
    private func fieldNumber(title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption)
            TextField("0", value: value, formatter: NumberFormatter.decimalNoGrouping)
                .keyboardType(.numberPad)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
        }
    }
    
    
    // ========================================================
    // MARK: - CUSTOMIZATION SECTION (MATCH OVERLAY DESIGN)
    // ========================================================
    
    var customizationSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            
            Text("Customization Options")
                .font(.system(size: 17, weight: .semibold))
            
            ForEach($optionGroups) { $group in
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    // HEADER with delete button
                    HStack {
                        TextField("Section Name", text: $group.category)
                            .font(.system(size: 14, weight: .semibold))
                        
                        Spacer()
                        
                        Button {
                            if let idx = optionGroups.firstIndex(where: { $0.id == group.id }) {
                                optionGroups.remove(at: idx)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // MIN + MAX selection
                    HStack {
                        // MIN (boleh 0)
                        Stepper(
                            "Min: \(group.minSelect)",
                            value: Binding(
                                get: { group.minSelect },
                                set: { newValue in
                                    let maxAllowed = group.choices.count
                                    let value = min(max(0, newValue), maxAllowed)
                                    group.minSelect = value

                                    // pastikan max >= min
                                    if group.maxSelect < value {
                                        group.maxSelect = value == 0 ? 1 : value
                                    }
                                }
                            ),
                            in: 0...max(0, group.choices.count)
                        )

                        // MAX (>= min)
                        Stepper(
                            "Max: \(group.maxSelect)",
                            value: Binding(
                                get: { group.maxSelect },
                                set: { newValue in
                                    let maxAllowed = max(1, group.choices.count)
                                    let value = min(max(1, newValue), maxAllowed)
                                    group.maxSelect = value
                                    
                                    // Ensure max >= min
                                    if value < group.minSelect {
                                        group.maxSelect = group.minSelect == 0 ? 1 : group.minSelect
                                    }
                                }
                            ),
                            in: 1...max(1, group.choices.count)
                        )
                    }
                    .font(.caption)



                    
                    // OPTION LIST
                    VStack(spacing: 12) {
                        ForEach($group.choices) { $choice in
                            optionRow(option: $choice)
                        }
                        
                        Button {
                            group.choices.append(
                                MenuOptionChoice(name: "", additionalPrice: 0)
                            )
                        } label: {
                            Text("+ Add option")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.orange.opacity(0.12)))
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .onChange(of: group.choices.count) { _, newCount in
                    let maxAllowed = max(1, newCount)

                    // Clamp max
                    if group.maxSelect > maxAllowed {
                        group.maxSelect = maxAllowed
                    }

                    // Clamp min (can be 0)
                    if group.minSelect > newCount {
                        group.minSelect = newCount
                    }

                    // Ensure max >= min
                    if group.maxSelect < max(group.minSelect, 1) {
                        group.maxSelect = max(group.minSelect, 1)
                    }
                }
            }
            
            // ADD NEW GROUP
            Button {
                optionGroups.append(
                    MenuOptionGroup(category: "", minSelect: 1, maxSelect: 1, choices: [])
                )
            } label: {
                Text("Add New Section")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.orange))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    private func optionRow(option: Binding<MenuOptionChoice>) -> some View {
        HStack(spacing: 10) {
            
            TextField("Name", text: option.name)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3))
                )
            
            Text("Rp +")
                .foregroundColor(.gray)
            
            TextField("0", value: option.additionalPrice, formatter: NumberFormatter.decimalNoGrouping)
                .keyboardType(.numberPad)
                .padding(10)
                .frame(width: 80)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3))
                )
        }
    }
    
    
    // ========================================================
    // MARK: - SAVE BUTTON
    // ========================================================
    
    var saveButton: some View {
        VStack {
            Button {
                var updated = item
                updated.options = optionGroups
                onSave(updated)
                dismiss()
            } label: {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}

extension NumberFormatter {
    static var decimalNoGrouping: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }
}

extension String {
    var wordCount: Int {
        self
            .split { $0.isWhitespace || $0.isNewline }
            .count
    }
}

