//
//  EditMenuTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 10/11/25.
//

import SwiftUI

struct EditMenuTenantView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State var item: MenuItem
    var onSave: (MenuItem) -> Void
    
    private let minutesChoices = Array(stride(from: 5, through: 120, by: 5))
    
    @State private var customizationGroups: [CustomizationGroup] = [
        CustomizationGroup(
            title: "Noodle Type",
            selectionType: "Choose 1",
            options: [
                CustomizationOption(name: "Thick", additionalPrice: 0),
                CustomizationOption(name: "Thin", additionalPrice: 0)
            ]
        ),
        CustomizationGroup(
            title: "Level",
            selectionType: "Choose 1",
            options: [
                CustomizationOption(name: "Sleeping (Lvl. 0)", additionalPrice: 0),
                CustomizationOption(name: "Angry (Lvl. 5)", additionalPrice: 1550),
                CustomizationOption(name: "Crazy (Lvl. 10)", additionalPrice: 3100)
            ]
        ),
        CustomizationGroup(
            title: "Topping",
            selectionType: "Choose 1",
            options: [
                CustomizationOption(name: "Classic", additionalPrice: 0),
                CustomizationOption(name: "Chicken Chashu", additionalPrice: 12400),
                CustomizationOption(name: "US Beef", additionalPrice: 21700)
            ]
        ),
        CustomizationGroup(
            title: "Condiment",
            selectionType: "Choose at least 2",
            options: [
                CustomizationOption(name: "Fried chillies", additionalPrice: 0),
                CustomizationOption(name: "Fried onions", additionalPrice: 0),
                CustomizationOption(name: "Chilli powder", additionalPrice: 0)
            ]
        )
    ]
    
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
                
                VStack {
                    Button {
                        var updated = item                      // copy
                        updated.customizationGroups = customizationGroups  // simpan perubahan
                        
                        onSave(updated)                         // kirim kembali ke parent
                        dismiss()
                    } label: {
                        Text("Save Changes")
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
            .navigationTitle("Edit Item")
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
        }
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private extension EditMenuTenantView {
    
    func addNewSection() {
        let newSection = CustomizationGroup(
            title: "New Section",
            selectionType: "Choose 1",
            options: []
        )
        customizationGroups.append(newSection)
    }
    
    func addOption(to group: CustomizationGroup) {
        if let index = customizationGroups.firstIndex(where: { $0.id == group.id }) {
            let newOption = CustomizationOption(
                name: "New Option",
                additionalPrice: 0
            )
            customizationGroups[index].options.append(newOption)
        }
    }
}

private extension EditMenuTenantView {
    var itemPictureSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Item Picture")
                .font(.system(size: 17, weight: .semibold))
            
            HStack(alignment: .top, spacing: 14) {
                
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 98, height: 98)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    HStack(spacing: 10) {
                        Button {} label: {
                            Text("Choose File")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.orange.opacity(0.15)))
                        }
                        .fixedSize()
                        
                        Text(item.imageFileName)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    Text("A clear, square image looks best")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    // Stock
                    HStack(spacing: 10) {
                        Text("Current Stock:")
                            .font(.system(size: 15))
                        
                        HStack(spacing: 0) {
                            Button {
                                if item.stock > 0 { item.stock -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(width: 32, height: 32)
                            }
                            
                            Text("\(item.stock)")
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 40)
                            
                            Button {
                                if item.stock < 999 { item.stock += 1 }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(width: 32, height: 32)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
            }
        }
    }
    
    var itemInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Item Information")
                .font(.system(size: 17, weight: .semibold))
            
            // NAME
            VStack(alignment: .leading, spacing: 6) {
                Text("Item Name")
                    .font(.caption)
                
                TextField("Enter name", text: $item.name)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    )
            }
            
            // DESCRIPTION
            VStack(alignment: .leading, spacing: 6) {
                Text("Short description")
                    .font(.caption)
                
                ZStack(alignment: .topLeading) {
                    
                    if item.shortDescription.isEmpty {
                        Text("Enter short description...")
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                    }
                    
                    CustomTextEditor(text: $item.shortDescription)
                        .frame(minHeight: 90)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3))
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                )
            }
            
            // PRICE + PREP TIME
            HStack(spacing: 12) {
                
                // PRICE
                VStack(alignment: .leading, spacing: 6) {
                    Text("Base Price (Rp)")
                        .font(.caption)
                    
                    TextField("35000",
                              value: $item.price,
                              formatter: NumberFormatter.decimalNoGrouping)
                    .keyboardType(.numberPad)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3))
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    )
                }
                
                // PREP TIME
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prep Time (Minimum)")
                        .font(.caption)
                    
                    HStack(spacing: 8) {
                        Picker("", selection: $item.prepMinutes) {
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
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    )
                }
            }
            HStack {
                (
                    Text("Customer sees: ") +
                    Text("\(item.prepMinutes + 10)")
                        .fontWeight(.semibold)
                        .foregroundColor(.orange) +
                    Text(" mins (\(item.prepMinutes) min prep + 10 min buffer)")
                )
                .font(.system(size: 13))
            }
            .padding(.horizontal, 21)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.12)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange.opacity(0.25)))
            
            Text("Time must be accurate within 10 mins tolerance to avoid penalty")
                .font(.caption2)
                .foregroundColor(.red)
                .padding(.horizontal, 14)
        }
    }
    
    var customizationSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            
            Text("Customization Options")
                .font(.system(size: 17, weight: .semibold))
            
            ForEach($customizationGroups) { $group in
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        TextField("Section Name", text: $group.title)
                            .font(.system(size: 14, weight: .semibold))
                        
                        Spacer()
                        
                        Button("Delete Group") {
                            if let index = customizationGroups.firstIndex(where: { $0.id == group.id }) {
                                customizationGroups.remove(at: index)
                            }
                        }
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // OPTIONS LIST
                    VStack(spacing: 12) {
                        ForEach($group.options) { $option in
                            HStack(spacing: 10) {
                                
                                // Editable Option Name
                                TextField("Name", text: $option.name)
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
                                
                                // Price field
                                TextField("0",
                                          value: $option.additionalPrice,
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
                        
                        // ADD OPTION KHUSUS GROUP INI
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
                .padding(.bottom, 4)
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
}

extension NumberFormatter {
    static var decimalNoGrouping: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }
}

#Preview {
    EditMenuTenantView(
        item: MenuItem(
            name: "Sample Item",
            price: 35000,
            stock: 10,
            shortDescription: "Dummy description for preview.",
            prepMinutes: 15,
            imageName: "ChickenKatsuShirokaraRamen",
            imageFileName: "default.jpg"
        ),
        onSave: { _ in }
    )
}
