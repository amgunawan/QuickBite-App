//
//  AddMenuItemOverlay.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI
import PhotosUI

struct AddMenuItemOverlay: View {

    @Environment(\.dismiss) private var dismiss

    // MARK: New Item Fields
    @State private var itemPicture: UIImage? = nil
    @State private var pickedImage: PhotosPickerItem? = nil
    @State private var fileName: String = "No file chosen"

    @State private var itemName = ""
    @State private var shortDescription = ""
    @State private var price: Int = 0
    @State private var prepMinutes: Int = 10

    // MARK: Customization Groups
    @State private var customizationGroups: [CustomizationGroup] = []

    var onSave: (MenuItem) -> Void

    private let minutesChoices = Array(stride(from: 5, through: 120, by: 5))

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
            .navigationTitle("Add New Item")
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
        }
        .presentationDetents([.fraction(0.95)])
        .presentationCornerRadius(22)
        .background(Color.white)
    }
}

extension AddMenuItemOverlay {

    // MARK: ITEM PICTURE SECTION
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

    // MARK: ITEM INFORMATION SECTION
    private var itemInformationSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("Item Information")
                .font(.system(size: 17, weight: .semibold))

            // NAME
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
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            // DESCRIPTION
            VStack(alignment: .leading, spacing: 6) {
                Text("Short description")
                    .font(.caption)

                ZStack(alignment: .topLeading) {

                    if shortDescription.isEmpty {
                        Text("A short, enticing description...")
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                    }

                    CustomTextEditor(text: $shortDescription)
                        .frame(minHeight: 90)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3))
                )
            }

            // PRICE + PREP TIME
            HStack(spacing: 12) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Base Price (Rp)")
                        .font(.caption)

                    TextField("35000",
                              value: $price,
                              formatter: NumberFormatter.decimalNoGrouping)
                        .keyboardType(.numberPad)
                        .font(.system(size: 15))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Prep Time (Minimum)")
                        .font(.caption)

                    HStack(spacing: 8) {
                        Picker("", selection: $prepMinutes) {
                            ForEach(minutesChoices, id: \.self) { m in
                                Text("\(m)").tag(m)
                            }
                        }
                        .pickerStyle(.menu)

                        Text("mins")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3))
                    )
                }
            }

            customerSeesBlock
        }
    }

    private var customerSeesBlock: some View {
        (
            Text("Customer sees: ") +
            Text("\(prepMinutes + 10)")
                .fontWeight(.semibold)
                .foregroundColor(.orange) +
            Text(" mins (\(prepMinutes) min prep + 10 min buffer)")
        )
        .font(.system(size: 13))
        .padding(.horizontal, 21)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.12)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange.opacity(0.25)))
    }

    // MARK: CUSTOMIZATION SECTION
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 22) {

            Text("Customization Options")
                .font(.system(size: 17, weight: .semibold))

            ForEach($customizationGroups) { $group in

                VStack(alignment: .leading, spacing: 10) {

                    // Group Header
                    HStack {
                        TextField("Section Name", text: $group.title)
                            .font(.system(size: 14, weight: .semibold))

                        Spacer()

                        Button("Delete Group") {
                            if let idx = customizationGroups.firstIndex(where: { $0.id == group.id }) {
                                customizationGroups.remove(at: idx)
                            }
                        }
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    // Options List
                    VStack(spacing: 12) {
                        ForEach($group.options) { $option in
                            optionRow(option: $option)
                        }

                        Button {
                            addOption(to: group)
                        } label: {
                            Text("+ Add option")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.orange)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.orange.opacity(0.12)))
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }

            Button {
                addNewSection()
            } label: {
                Text("Add New Section")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.orange))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: OPTION ROW
    private func optionRow(option: Binding<CustomizationOption>) -> some View {
        HStack(spacing: 10) {

            TextField("Name", text: option.name)
                .font(.system(size: 15))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Text("Rp +")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            TextField("0",
                      value: option.additionalPrice,
                      formatter: NumberFormatter.decimalNoGrouping)
                .keyboardType(.numberPad)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(width: 90, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: SAVE BUTTON
    private var saveButton: some View {
        VStack {
            Button {
                let newItem = MenuItem(
                    name: itemName,
                    price: price,
                    stock: 10,
                    shortDescription: shortDescription,
                    prepMinutes: prepMinutes,
                    imageName: "placeholder",
                    imageFileName: fileName,
                    customizationGroups: customizationGroups
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
                        Color.orange,
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: LOGIC FUNCTIONS
    private func addNewSection() {
        let newGroup = CustomizationGroup(
            title: "",
            selectionType: "Choose 1",
            options: []
        )
        customizationGroups.append(newGroup)
    }

    private func addOption(to group: CustomizationGroup) {
        if let idx = customizationGroups.firstIndex(where: { $0.id == group.id }) {
            customizationGroups[idx].options.append(
                CustomizationOption(name: "", additionalPrice: 0)
            )
        }
    }

    private func loadSelectedImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                self.itemPicture = img
                self.fileName = await item.itemIdentifier ?? "selected.jpg"
            }
        }
    }
}

