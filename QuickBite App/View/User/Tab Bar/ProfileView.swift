//
//  ProfileView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

//
//  ProfileView.swift
//  QuickBite App
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
                RoundedRectangle(cornerRadius: 8)
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
    let profileImage: UIImage?
    var onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            // === SHOW USER AVATAR OR DEFAULT ICON ===
            if let img = profileImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle().fill(Color.orange.opacity(0.18))
                    Image(systemName: "person.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
                .frame(width: 48, height: 48)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.headline)
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.orange)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
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
    @State private var fullName: String =
        UserDefaults.standard.string(forKey: "user.fullName") ?? "Angela Melia Gunawan"

    @State private var phoneCode: String = "+62"
    @State private var phone: String =
        UserDefaults.standard.string(forKey: "user.phone") ?? "81230300020"

    @State private var points: Int = 30

    // === NEW: profile image state for user ===
    @State private var profileImage: UIImage? = nil

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

                    // === UPDATED PROFILE CARD ===
                    ProfileCard(
                        username: username,
                        email: email,
                        profileImage: profileImage    // << IMPORTANT
                    ) {
                        showEdit = true
                    }
                    .padding(.horizontal)
                    .offset(y: -10)
                    .zIndex(1)

                    // === SETTINGS LIST ===
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
                    .padding(.top, -20)
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
                    onSave: {
                        showEdit = false
                        reloadAvatar()   // ⬅ AUTO UPDATE IMAGE
                    }
                )
            }
        }
        .onAppear {
            reloadAvatar()
        }
    }

    private func reloadAvatar() {
        if let data = UserDefaults.standard.data(forKey: "user.avatar"),
           let img = UIImage(data: data) {
            profileImage = img
        } else {
            profileImage = nil
        }
    }
}

#Preview {
    ProfileView()
}
