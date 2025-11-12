//
//  ProfileView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct SettingsRowLabel: View {
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
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProfileCard: View {
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

struct ProfileView: View {
    @State private var username: String = "agunawan18"
    @State private var email: String = "agunawan18@student.ciputra.ac.id"
    @State private var language: String = "English"

    @State private var showEdit = false
    @State private var fullName: String = "Angela Melia Gunawan"
    @State private var phoneCode: String = "+62"
    @State private var phone: String = "81230300020"
    @State private var points: Int = 30

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    HeaderBackgroundView(height: 100)
                    
                    Spacer()
                }

                VStack(spacing: 0) {
                    Text("Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ProfileCard(username: username, email: email) {
                        showEdit = true
                    }
                    .padding(.horizontal)
                    .offset(y: -10)
                    .zIndex(1)

                    List {
                        Section("Settings") {
                            NavigationLink {
                                ChangePasswordView()
                            } label: {
                                SettingsRowLabel(systemIcon: "lock.fill",
                                                 tint: .gray,
                                                 title: "Change Password")
                            }
                            
                            NavigationLink {
                                LanguageSelectionView(selectedLanguage: $language)
                            } label: {
                                SettingsRowLabel(systemIcon: "globe",
                                                 tint: .gray,
                                                 title: "Languages",
                                                 trailing: language)
                            }
                            
                            NavigationLink {
                                HelpSupportView()
                            } label: {
                                SettingsRowLabel(systemIcon: "questionmark.circle",
                                                 tint: .gray,
                                                 title: "Help & Support")
                            }
                            
                            NavigationLink {
                                FAQView()
                            } label: {
                                SettingsRowLabel(systemIcon: "questionmark.bubble",
                                                 tint: .gray,
                                                 title: "FAQ")
                            }
                            
                            NavigationLink {
                                TermsServiceView()
                            } label: {
                                SettingsRowLabel(systemIcon: "doc.text",
                                                 tint: .gray,
                                                 title: "Terms & Service")
                            }
                            
                            NavigationLink {
                                ManageAccountView()
                            } label: {
                                SettingsRowLabel(systemIcon: "gearshape",
                                                 tint: .gray,
                                                 title: "Manage Account")
                            }
                        }
                        .foregroundColor(.black)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.top,-20)
                    .scrollDisabled(true)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showEdit) {
                EditProfileView(
                    username: username,
                    fullName: $fullName,
                    phoneCode: $phoneCode,
                    phone: $phone,
                    email: $email,
                    points: points,
                    onSave: { showEdit = false }
                )
            }
        }
    }
}

#Preview {
    ProfileView()
}
