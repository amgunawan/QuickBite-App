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
                Text(username)
                    .font(.headline)

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
    @EnvironmentObject var authVM: AuthenticationViewModel

    @State private var showEditProfile = false
    @State private var tenantLanguage = "English"

    private var session: AppUserSession? {
        authVM.currentUserSession
    }

    var body: some View {
        NavigationStack {
            Group {
                if let session {
                    content(session: session)
                } else {
                    ProgressView("Loading profile...")
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            Task { await vm.loadProfileImage() }
        }
    }

    @ViewBuilder
    private func content(session: AppUserSession) -> some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {
                HeaderBackgroundView(height: 100)
                Spacer()
            }

            VStack(spacing: 0) {

                Text("Store Profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // === PROFILE CARD (SAMA SEPERTI VERSI LAMA) ===
                TenantProfileCard(
                    username: session.email.components(separatedBy: "@").first ?? "Merchant",
                    email: session.email,
                    image: vm.tenantProfileImage
                ) {
                    showEditProfile = true
                }
                .padding(.horizontal)
                .offset(y: -10)
                .zIndex(1)

                // ❌ TIDAK ADA SPACER DI SINI

                List {

                    // === STORE MANAGEMENT ===
                    Section(header: Text("Store Management")) {

                        if let storeId = session.storeId {

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
                                EditStoreDetailsTenantView(storeId: storeId)
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "shippingbox",
                                    tint: .gray,
                                    title: "Edit Store Details"
                                )
                            }

                            NavigationLink {
                                DiscountListTenantView(storeId: storeId)
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "tag.fill",
                                    tint: .gray,
                                    title: "Discount"
                                )
                            }

                            NavigationLink {
                                FinancialPayoutsTenantView(storeId: storeId)
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "creditcard",
                                    tint: .gray,
                                    title: "Financial & Payouts"
                                )
                            }

                        } else {
                            TenantSettingsRowLabel(
                                systemIcon: "exclamationmark.triangle",
                                tint: .orange,
                                title: "Store not linked yet"
                            )
                        }
                    }

                    // === ACCOUNT & SUPPORT (SEJAJAR, BUKAN NESTED) ===
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
                                selectedLanguage: $tenantLanguage
                            )
                        } label: {
                            TenantSettingsRowLabel(
                                systemIcon: "globe",
                                tint: .gray,
                                title: "Languages",
                                trailing: tenantLanguage
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
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileTenantView(
                    viewModel: vm,
                    tenantusername: session.email,
                    tenantfullName: $vm.tenantFullName,
                    tenantemail: .constant(session.email),
                    onSave: {
                        Task {
                            await vm.updateFullName(vm.tenantFullName)
                            showEditProfile = false
                        }
                    }
                )
            }
        }
    }
}
