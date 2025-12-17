//
//  StoreLocationDetailsView.swift
//  QuickBite
//

import SwiftUI

struct StoreLocationDetailsView: View {

    @EnvironmentObject var storeVM: StoreRegistrationViewModel
    
    @EnvironmentObject var authVM: AuthenticationViewModel

    let locations = ["UC Walk", "Denver Food"]
    let categories = ["Snacks", "Rice", "Noodles", "Chicken", "Korean", "Japanese", "Beverages", "Chinese", "Western"]

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        VStack(spacing: 20) {

            RegistrationHeader(
                step: 1,
                title: "Store & Location Details",
                subtitle: "Enter your primary business informations and location."
            )

            VStack(spacing: 0) {

                TextField("Store Name", text: $storeVM.storeName)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .onChange(of: storeVM.storeName) { _, newValue in
                        Task {
                            await storeVM.validateStoreNameUniqueness(newValue)
                        }
                    }

                if let error = storeVM.storeNameError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Divider()

                HStack {
                    Picker("Location", selection: $storeVM.location) {
                        Text("Select your merchant area").tag("")
                        ForEach(locations, id: \.self) { loc in
                            Text(loc).tag(loc)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(height: 50)
                    .tint(.orange)

                    Spacer()
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {

                Text("Food Category (Choose up to 2)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: {
                                toggleCuisine(cat)
                            }) {
                                HStack {
                                    Text(cat)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(
                                                storeVM.cuisineTypes.contains(cat)
                                                ? Color.orange
                                                : Color.gray.opacity(0.5),
                                                lineWidth: 2
                                            )
                                            .frame(width: 24, height: 24)

                                        if storeVM.cuisineTypes.contains(cat) {
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
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }

            NavigationLink(destination: KTPVerificationView()) {
                OrangeButton(title: "Continue", enabled: canContinue)
            }
            .disabled(!canContinue)
            .simultaneousGesture(TapGesture().onEnded {
                storeVM.saveDraft()
                Task {
                    do {
                        // update step to 2 (KTP)
                        try await authVM.updateOnboardingStep(2)
                    } catch {
                        print("Failed to update onboarding step: \(error.localizedDescription)")
                    }
                }
            })
            .padding()
        }
    }

    // ✅ VALIDATION USING VIEWMODEL
    private var canContinue: Bool {
        !storeVM.storeName.isEmpty &&
        storeVM.storeNameError == nil &&
        !storeVM.isCheckingStoreName &&
        !storeVM.location.isEmpty &&
        !storeVM.cuisineTypes.isEmpty
    }

    // ✅ CUISINE TYPE TOGGLE (MAX 2)
    private func toggleCuisine(_ cat: String) {
        if storeVM.cuisineTypes.contains(cat) {
            storeVM.cuisineTypes.removeAll { $0 == cat }
        } else if storeVM.cuisineTypes.count < 2 {
            storeVM.cuisineTypes.append(cat)
        }
    }
}

#Preview {
    NavigationView {
        StoreLocationDetailsView()
            .environmentObject(StoreRegistrationViewModel())
    }
}
