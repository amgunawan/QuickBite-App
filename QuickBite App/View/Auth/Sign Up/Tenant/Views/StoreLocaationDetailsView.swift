//
//  StoreLocaationDetailsView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct StoreLocationDetailsView: View {
    @State private var storeName = ""
    @State private var selectedLocation = ""
    @State private var foodCategories: Set<String> = []
    
    let locations = ["UC Walk", "Denver Food"]
    let categories = ["Snacks", "Rice", "Noodles", "Chicken", "Korean", "Japanese", "Beverages", "Chinese", "Western"]
    
    var body: some View {
        VStack(spacing: 20) {
            RegistrationHeader(step: 1,
                               title: "Store & Location Details",
                               subtitle: "Enter your business information and location.")
            
            Form {
                Section {
                    TextField("Store Name (e.g., Raburi Japanese Food)", text: $storeName)
                    
                    Picker("Location", selection: $selectedLocation) {
                        Text("Select your merchant area").tag("")
                        ForEach(locations, id: \.self) { loc in
                            Text(loc).tag(loc)
                        }
                    }
                }
                
                Section(header: Text("Food Category (Choose up to 2)")) {
                    ForEach(categories, id: \.self) { cat in
                        Button(action: {
                            toggleCategory(cat)
                        }) {
                            HStack {
                                Text(cat)
                                    .foregroundColor(.primary)
                                Spacer()
                                
                                // ✅ Custom Rounded Square Checkbox
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(foodCategories.contains(cat) ? Color.orange : Color.gray.opacity(0.5), lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    
                                    if foodCategories.contains(cat) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .bold))
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.orange)
                                                    .frame(width: 24, height: 24)
                                            )
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Disable default button styling
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            NavigationLink(destination: MenuDetailsView(),
                           label: {
                OrangeButton(title: "Continue", action: {}, enabled: canContinue)
            })
            .simultaneousGesture(TapGesture().onEnded {
                hideKeyboard()
            })
            .padding()
        }
    }
    
    private var canContinue: Bool {
        !storeName.isEmpty && !selectedLocation.isEmpty && !foodCategories.isEmpty
    }
    
    private func toggleCategory(_ cat: String) {
        if foodCategories.contains(cat) {
            foodCategories.remove(cat)
        } else if foodCategories.count < 2 {
            foodCategories.insert(cat)
        }
    }
}

#Preview {
    NavigationView {
        StoreLocationDetailsView()
    }
}
