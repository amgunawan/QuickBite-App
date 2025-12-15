//
//  TenantProfileView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

struct TenantSettingsRowLabel: View {
    let systemIcon: String
    let tint: Color
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                Image(systemName: systemIcon)
                    .foregroundColor(tint)
                    .font(.subheadline)
            }
            .frame(width: 28, height: 28)

            Text(title)
                .foregroundColor(.primary)
            Spacer()

            if let trailingText = trailing {
                Text(trailingText)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TenantProfileCard: View {
    @StateObject private var vm = TenantProfileViewModel()
    
    let username: String
    let email: String
    var image: UIImage? = nil
    var onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Circle().fill(Color.orange.opacity(0.18))
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(username).font(.headline)
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.orange)
                    .padding(8)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
    }
}

struct TenantProfileView: View {
    @StateObject private var vm = TenantProfileViewModel()
    
    let storeId = "2plb4UCwxjle2Yy6PTdj"
    @State private var showEditProfile = false
    @State private var tenantlanguage = "English"

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                VStack(spacing: 0) {
                    HeaderBackgroundView(height: 100)
                    Spacer()
                }

                VStack(spacing: 0) {
                    Text("Store Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // === PROFILE CARD ===
                    TenantProfileCard(
                        username: vm.tenantUsername,
                        email: vm.tenantEmail,
                        image: vm.tenantProfileImage
                    ) {
                        showEditProfile = true
                    }
                    .padding(.horizontal)
                    .offset(y: -10)
                    .zIndex(1)

                    Spacer()

                    // === MENU LIST ===
                    List {
                        Section(header: Text("Store Management")) {
                            NavigationLink {
                                ManageMenuStockTenantView(storeId: storeId)
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "fork.knife",
                                    tint: .gray,
                                    title: "Manage Menu & Stock"
                                )
                            }

                            NavigationLink {
                                EditStoreDetailsTenantView()
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "shippingbox",
                                    tint: .gray,
                                    title: "Edit Store Details"
                                )
                            }

                            NavigationLink {
                                FinancialPayoutsTenantView()
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "creditcard",
                                    tint: .gray,
                                    title: "Financial & Payouts"
                                )
                            }
                        }

                        Section("Account & Support") {
                            NavigationLink {
                                ChangePasswordTenantView()
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "lock.fill",
                                    tint: .gray,
                                    title: "Change Password"
                                )
                            }

                            NavigationLink {
                                LanguageSelectionTenantView(
                                    selectedLanguage: $tenantlanguage
                                )
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "globe",
                                    tint: .gray,
                                    title: "Languages",
                                    trailing: tenantlanguage
                                )
                            }

                            NavigationLink {
                                HelpSupportTenantView()
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "questionmark.circle",
                                    tint: .gray,
                                    title: "Help & Support"
                                )
                            }

                            NavigationLink {
                                FAQTenantView()
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "questionmark.bubble",
                                    tint: .gray,
                                    title: "FAQ"
                                )
                            }

                            NavigationLink {
                                TermsServiceTenantView()
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "doc.text",
                                    tint: .gray,
                                    title: "Terms & Service"
                                )
                            }

                            NavigationLink {
                                ManageAccountTenantView()
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "gearshape",
                                    tint: .gray,
                                    title: "Manage Account"
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.top, -20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)

            // === EDIT PROFILE ===
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileTenantView(
                    viewModel: vm,
                    tenantusername: vm.tenantUsername,
                    tenantfullName: $vm.tenantFullName,
                    tenantemail: .constant(vm.tenantEmail),
                    onSave: {
                        Task {
                            await vm.updateFullName(vm.tenantFullName)
                            showEditProfile = false
                        }
                    }
                )
            }
        }
        .onAppear {
            vm.loadTenantFromEmail()
            Task {
                await vm.loadProfileImage()
            }
        }
    }
}
