//
//  SignUpFormTenantView.swift
//  QuickBite App
//
//  Created by jessica tedja on 10/11/25.
//

import SwiftUI

struct OrangeButton: View {
    let title: String
    let action: () -> Void
    var enabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(enabled ? Color.orange : Color.gray.opacity(0.3))
                .cornerRadius(100)
        }
        .disabled(!enabled)
    }
}

struct RegistrationHeader: View {
    let step: Int
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(step) of 4")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

struct SignUpFormTenantView: View {
    var body: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 16) {
                Text("Reach out more customers with QuickBite")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Maximize sales during UC’s rush hour!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 24) {
                FeatureRow(icon: "person.3.fill",
                           title: "Guaranteed Daily Traffic",
                           subtitle: "Tap directly into hungry and time-constrained UC students.")
                
                FeatureRow(icon: "creditcard.fill",
                           title: "Merchant Payout Protection",
                           subtitle: "QuickBite will charge Rp. 2,500/order billed directly to the customer.")
                
                FeatureRow(icon: "clock.fill",
                           title: "Optimized Pre-Orders",
                           subtitle: "Receive orders in advance to prepare for rush hours.")
            }
            .padding(.horizontal)
            
            Spacer()
            
            NavigationLink(destination: StoreLocationDetailsView()) {
                Text("Start Registration")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(100)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct FeatureRow: View {
    var icon: String
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

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
                        MultipleSelectionRow(title: cat,
                                             isSelected: foodCategories.contains(cat)) {
                            toggleCategory(cat)
                        }
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

// MARK: - Step 2: Menu Details
struct MenuDetailsView: View {
    @State private var menuItems: [String] = [""]
    
    var body: some View {
        VStack(spacing: 20) {
            RegistrationHeader(step: 2,
                               title: "Menu Details",
                               subtitle: "List your top-selling items for QuickBite.")
            
            Form {
                ForEach(menuItems.indices, id: \.self) { index in
                    TextField("Menu Item \(index + 1)", text: $menuItems[index])
                }
                
                Button(action: {
                    menuItems.append("")
                }) {
                    Label("Add Another Item", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            
            NavigationLink(destination: OperatingHoursView()) {
                OrangeButton(title: "Continue", action: {}, enabled: !menuItems.allSatisfy { $0.isEmpty })
            }
            .padding()
        }
    }
}

// MARK: - Step 3: Operating Hours
struct OperatingHoursView: View {
    @State private var openingTime = Date()
    @State private var closingTime = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            RegistrationHeader(step: 3,
                               title: "Operating Hours",
                               subtitle: "Set your daily operating times.")
            
            Form {
                DatePicker("Opening Time", selection: $openingTime, displayedComponents: .hourAndMinute)
                DatePicker("Closing Time", selection: $closingTime, displayedComponents: .hourAndMinute)
            }
            
            NavigationLink(destination: ConfirmationView()) {
                OrangeButton(title: "Continue", action: {}, enabled: true)
            }
            .padding()
        }
    }
}

// MARK: - Step 4: Confirmation
struct ConfirmationView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            Text("Registration Complete!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your QuickBite registration has been submitted successfully. We'll contact you soon!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            NavigationLink(destination: HomeView()) {
                OrangeButton(title: "Go to Home", action: {}, enabled: true)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .orange : .gray)
            }
        }
    }
}

#Preview {
    SignUpFormTenantView()
}
