//
//  TenantProfileView.swift
//  QuickBite
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

            if let trailing {
                Text(trailing)
                    .foregroundColor(.primary)
            }

        }
        .padding(.vertical, 4)
    }
}

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
    @State private var username: String = "sharontan1"
    @State private var email: String = "sharontan1@gmail.com"
    @State private var language: String = "English"

    @State private var showEdit = false
    @State private var fullName: String = "Sharon Tan"
    @State private var phoneCode: String = "+62"
    @State private var phone: String = "82134584979"
    @State private var points: Int = 30

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
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Profile card
                    TenantProfileCard(username: username, email: email) {
                        showEdit = true
                    }
                    .padding(.horizontal)
                    .offset(y: -10)
                    .zIndex(1)

                    // Menu list
                    List {
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
                                    systemIcon: "pencil.and.scribble",
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

                        // MARK: Account & Support
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
                                LanguageSelectionTenantView(selectedLanguage: $language)
                            } label: {
                                TenantSettingsRowLabel(
                                    systemIcon: "globe",
                                    tint: .gray,
                                    title: "Languages",
                                    trailing: language
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
                    .padding(.top, -20) // supaya nempel dengan header
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showEdit) {
                EditProfileView(
                    username: username,
                    fullName: $fullName,
                    phoneCode: $phoneCode,
                    phone: $phone,
                    email: $email,
                    points: points,
                    onSave: { showEdit = false }
                )
                .presentationDetents([.medium, .large])
                .scrollDisabled(true)

            }
        }
    }
}

#Preview {
    TenantProfileView()
}
