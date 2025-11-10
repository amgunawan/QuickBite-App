import SwiftUI

// MARK: - Row Label (tanpa NavigationView)
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

            if let trailing {
                Text(trailing)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Profile Card
struct TenantProfileCard: View {
    let username: String
    let email: String
    var onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.18))
                Image(systemName: "person.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
            .frame(width: 48, height: 48)

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

// MARK: - Tenant Profile View
struct TenantProfileView: View {
    @State private var tenantusername = "sharontan1"
    @State private var tenantemail = "sharontan1@gmail.com"
    @State private var tenantlanguage = "English"

    @State private var showEditProfile = false
    @State private var tenantfullName = "Sharon Tan"
    @State private var tenantphoneCode = "+62"
    @State private var tenantphone = "82134584979"

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    HeaderBackgroundView(height: 100)
                    Spacer()
                }

                VStack(spacing: 10) {
                    Text("Store Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TenantProfileCard(username: tenantusername, email: tenantemail) {
                        showEditProfile = true
                    }
                    .padding(.horizontal)
                    .offset(y: -10)
                    .zIndex(1)

                    // === Menu List ===
                    List {
                        // SECTION 1
                        Section("Store Management") {
                            NavigationLink {
                                ManageMenuStockTenantView()
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

                        // SECTION 2
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
                                LanguageSelectionTenantView(selectedLanguage: $tenantlanguage)
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
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .padding(.top, -20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileTenantView(
                    tenantusername: tenantusername,
                    tenantfullName: $tenantfullName,
                    tenantphoneCode: $tenantphoneCode,
                    tenantphone: $tenantphone,
                    tenantemail: $tenantemail,
                    onSave: { showEditProfile = false }
                )
            }
        }
    }
}
