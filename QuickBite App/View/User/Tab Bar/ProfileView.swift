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
    @StateObject private var vm = ProfileViewModel()
    
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    @State private var editUsername: String = ""
    @State private var editEmail: String = ""
    
    private var userId: String? {
        authVM.currentUserSession?.uid
    }

    @State private var language: String = "English"

    @State private var showEdit = false
    @State private var fullName: String = ""

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
                        username: vm.user?.username ?? "-",
                        email: vm.user?.email ?? "-",
                        profileImage: vm.profileImage
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
                    username: vm.user?.username ?? "-",
                    fullName: $fullName,
                    email: vm.user?.email ?? "-",
                    points: points,
                    userId: userId ?? "",
                    vm: vm,
                    onSave: {
                        // Save full name to database
                        vm.updateFullName(to: fullName) { error in
                            if let error = error {
                                print("Failed to update full name:", error.localizedDescription)
                            } else {
                                print("Full name updated successfully")
                            }
                        }
                        
                        showEdit = false
                        reloadAvatar()
                    }
                )
            }
        }
        .onAppear {
            guard let userId else { return }
            vm.loadUser(userId: userId)
            vm.loadProfileImage(userId: userId)
        }
        
        .onReceive(vm.$user) { newUser in
            fullName = newUser?.full_name ?? ""
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
