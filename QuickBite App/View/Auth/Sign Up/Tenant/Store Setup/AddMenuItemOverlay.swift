//
//  AddMenuItemOverlay.swift
//  QuickBite
//

import SwiftUI
import PhotosUI

struct AddMenuItemOverlay: View {

    @Environment(\.dismiss) private var dismiss

    let existingItem: MenuItem?
    let category: String
    var onSave: (MenuItem) -> Void

    private let minutesChoices = Array(stride(from: 5, through: 120, by: 5))

    @State private var itemPicture: UIImage? = nil
    @State private var pickedImage: PhotosPickerItem? = nil
    @State private var fileName: String = "No file chosen"

    @State private var itemName = ""
    @State private var shortDescription = ""
    @State private var priceText: String = "0"
    @State private var prepMinutes: Int = 10
    @State private var stockText: String = "0"
    @State private var optionGroups: [MenuOptionGroup] = []

    init(existingItem: MenuItem? = nil, category: String = "", onSave: @escaping (MenuItem) -> Void) {
        self.existingItem = existingItem
        self.category = category
        self.onSave = onSave

        _itemName = State(initialValue: existingItem?.name ?? "")
        _shortDescription = State(initialValue: existingItem?.description ?? "")
        _priceText = State(initialValue: String(existingItem?.price ?? 0))
        _prepMinutes = State(initialValue: existingItem?.prepTimeMinutes ?? 10)
        _stockText = State(initialValue: String(existingItem?.defaultStock ?? 0))
        _optionGroups = State(initialValue: existingItem?.options ?? [])

        // ✅ THIS IS THE MISSING PIECE
        _itemPicture = State(initialValue: existingItem?.draftImage)

        // Optional: nicer filename label when editing and image already exists
        if existingItem?.draftImage != nil {
            _fileName = State(initialValue: "Selected image")
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        itemPictureSection
                        Divider()
                        itemInformationSection
                        Divider()
                        customizationSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                saveButton
            }
            .background(Color.white)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(existingItem == nil ? "Add New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onChange(of: pickedImage) { _, newValue in
                loadSelectedImage(newValue)
            }
            .onAppear {
                if existingItem == nil && prepMinutes == 0 {
                    prepMinutes = 10
                }
            }
        }
    }
}

extension AddMenuItemOverlay {

    // MARK: OPTION ROW
    private func optionRow(option: Binding<MenuOptionChoice>) -> some View {
        HStack(spacing: 10) {

            // OPTION NAME
            TextField("Name", text: option.name)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )

            Text("Rp +")
                .foregroundColor(.gray)

            // ADDITIONAL PRICE
            TextField(
                "0",
                value: option.additionalPrice,
                formatter: NumberFormatter.decimalNoGrouping
            )
            .keyboardType(.numberPad)
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: 80)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3))
            )
        }
    }

    // MARK: ITEM INFORMATION SECTION
    private var itemInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Item Information")
                .font(.system(size: 17, weight: .semibold))

            // ITEM NAME
            VStack(alignment: .leading, spacing: 6) {
                Text("Item Name")
                    .font(.caption)

                TextField("Enter name", text: $itemName)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3))
                    )
            }

            // DESCRIPTION
            VStack(alignment: .leading, spacing: 6) {
                Text("Short Description")
                    .font(.caption)

                ZStack(alignment: .topLeading) {
                    if shortDescription.isEmpty {
                        Text("A short, enticing description...")
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .allowsHitTesting(false)
                    }

                    CustomTextEditor(text: $shortDescription, wordLimit: 100)
                        .frame(minHeight: 90)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3))
                )
            }

            // PRICE + STOCK + PREP TIME
            HStack(spacing: 12) {
                
                // PRICE
                VStack(alignment: .leading, spacing: 6) {
                    Text("Base Price (Rp)")
                        .font(.caption)
                    
                    TextField("35000", text: $priceText)
                        .keyboardType(.numberPad)
                        .onChange(of: priceText) { _, v in
                            priceText = v.filter { $0.isNumber }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(width: 95, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                
                // STOCK
                VStack(alignment: .leading, spacing: 6) {
                    Text("Stock / Day")
                        .font(.caption)
                    
                    TextField("10", text: $stockText)
                        .keyboardType(.numberPad)
                        .onChange(of: stockText) { _, v in
                            stockText = v.filter { $0.isNumber }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(width: 95, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                
                // PREP TIME
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prep Time (Max)")
                        .font(.caption)
                    
                    HStack(spacing: 10) {
                        
                        Picker("", selection: $prepMinutes) {
                            ForEach(minutesChoices, id: \.self) { minute in
                                Text("\(minute)")
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.orange)   // number + chevron only
                        .frame(
                            minWidth: 64,
                            maxWidth: 72,
                            minHeight: 44,
                            maxHeight: 44
                        )
                        
                        Text("mins")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .frame(width: 160, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3))
                    )
                }
            }
        }
    }

    // MARK: CUSTOMIZATION SECTION
    // MARK: - CUSTOMIZATION SECTION (FINAL)
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 22) {

            Text("Customization Options")
                .font(.system(size: 17, weight: .semibold))

            ForEach($optionGroups) { $group in
                VStack(alignment: .leading, spacing: 14) {

                    // ===== GROUP HEADER =====
                    HStack {
                        TextField("Section Name", text: $group.category)
                            .font(.system(size: 14, weight: .semibold))

                        Spacer()

                        Button {
                            optionGroups.removeAll { $0.id == group.id }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // ===== MIN / MAX SELECT =====
                    HStack(spacing: 12) {

                        Stepper(
                            "Min: \(group.minSelect)",
                            value: Binding(
                                get: { group.minSelect },
                                set: { newValue in
                                    let maxAllowed = group.choices.count
                                    let value = min(max(0, newValue), maxAllowed)
                                    group.minSelect = value
                                    if group.maxSelect < value {
                                        group.maxSelect = max(value, 1)
                                    }
                                }
                            ),
                            in: 0...max(0, group.choices.count)
                        )

                        Stepper(
                            "Max: \(group.maxSelect)",
                            value: Binding(
                                get: { group.maxSelect },
                                set: { newValue in
                                    let maxAllowed = max(1, group.choices.count)
                                    let value = min(max(1, newValue), maxAllowed)
                                    group.maxSelect = value
                                    if value < group.minSelect {
                                        group.maxSelect = max(group.minSelect, 1)
                                    }
                                }
                            ),
                            in: 1...max(1, group.choices.count)
                        )
                    }
                    .font(.caption)

                    // ===== OPTIONS =====
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
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .onChange(of: group.choices.count) { _, newCount in
                    let maxAllowed = max(1, newCount)

                    if group.maxSelect > maxAllowed {
                        group.maxSelect = maxAllowed
                    }
                    if group.minSelect > newCount {
                        group.minSelect = newCount
                    }
                    if group.maxSelect < max(group.minSelect, 1) {
                        group.maxSelect = max(group.minSelect, 1)
                    }
                }
            }

            // ===== ADD NEW GROUP =====
            Button {
                optionGroups.append(
                    MenuOptionGroup(
                        category: "",
                        minSelect: 1,
                        maxSelect: 1,
                        choices: []
                    )
                )
            } label: {
                Text("Add New Section")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.orange))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var itemPictureSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Item Picture")
                .font(.system(size: 17, weight: .semibold))

            HStack(alignment: .top, spacing: 14) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))

                    if let img = itemPicture {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 98, height: 98)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 98, height: 98)

                VStack(alignment: .leading, spacing: 10) {

                    HStack(spacing: 10) {
                        PhotosPicker(selection: $pickedImage, matching: .images) {
                            Text("Choose File")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.orange.opacity(0.15)))
                        }

                        Text(fileName)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    Text("A clear, square image looks best")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    // (keep your itemInformationSection / customizationSection as-is)

    private var saveButton: some View {
        VStack {
            Button {
                let finalPrice = Int(priceText) ?? 0
                let finalStock = Int(stockText) ?? 0

                let idToUse = existingItem?.itemId ?? UUID().uuidString

                let newItem = MenuItem(
                    itemId: idToUse,
                    name: itemName,
                    description: shortDescription,
                    price: finalPrice,
                    category: category,
                    imageURL: existingItem?.imageURL,    // ✅ preserve Firebase URL if any
                    defaultStock: finalStock,
                    prepTimeMinutes: prepMinutes,
                    options: optionGroups,
                    draftImage: itemPicture              // ✅ keep draft image for preview
                )

                onSave(newItem)
                dismiss()

            } label: {
                Text("Save Item")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        canSave ? Color.orange : Color.gray.opacity(0.4),
                        in: RoundedRectangle(cornerRadius: 100)
                    )
            }
            .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var canSave: Bool {
        if itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if (Int(priceText) ?? 0) <= 0 { return false }
        if (Int(stockText) ?? 0) <= 0 { return false }
        if prepMinutes <= 0 { return false }
        return true
    }

    private func loadSelectedImage(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let original = UIImage(data: data) {

                // ✅ RESIZE TO SQUARE BEFORE USING
                let resized = ImageResizeHelper.resize(
                    original,
                    mode: .square,
                    maxSize: 800
                )

                await MainActor.run {
                    self.itemPicture = resized
                    self.fileName = "Selected image"
                }
            }
        }
    }
}

#Preview {
    AddMenuItemOverlay{ _ in }
}
