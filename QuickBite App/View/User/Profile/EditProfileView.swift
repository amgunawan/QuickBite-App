//
//  EditProfileView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct EditProfileView: View {
    let username: String
    @Binding var fullName: String
    @Binding var phoneCode: String
    @Binding var phone: String
    @Binding var email: String
    let points: Int

    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    enum Field { case fullName, phone, email }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Edit Profile")
                    .font(.headline)
                Spacer()
                Button("Save") {
                    onSave()
                }
                .font(.headline)
                .foregroundColor(.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [.orange, .orange.opacity(0.7)],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .frame(width: 96, height: 96)
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)

                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.black.opacity(0.9))
                                        .padding(6)
                                        .background(.white, in: Circle())
                                        .offset(x: 6, y: 6)
                                }
                            }
                            .frame(width: 96, height: 96)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                            Text("\(points) Points")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 6)

                    // FORM
                    VStack(spacing: 14) {
                        // Username (disabled)
                        VStack(alignment: .leading, spacing: 6) {
                            labelRequired("Username")
                            TextField("", text: .constant(username))
                                .disabled(true)
                                .textFieldStyle(.roundedBorder)
                                .opacity(0.7)
                        }

                        // Full Name + clear button
                        VStack(alignment: .leading, spacing: 6) {
                            labelRequired("Full Name")
                            HStack {
                                TextField("Your full name", text: $fullName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .fullName)

                                if !fullName.isEmpty {
                                    Button {
                                        fullName = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(10)
                            .background(.white, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        Color.orange.opacity(0.5),
                                        lineWidth: focusedField == .fullName ? 1.2 : 0.3
                                    )
                            )
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            labelRequired("Phone Number")
                            HStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Text("🇮🇩")
                                        .font(.body)
                                    Text(phoneCode)
                                        .font(.body)
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 44)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))

                                TextField("81230300020", text: $phone)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .phone)
                                    .font(.body) // samakan ukuran font
                                    .padding(10)
                                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            labelRequired("Email")
                            TextField("name@example.com", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func labelRequired(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
            Text("*").foregroundColor(.orange)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}
