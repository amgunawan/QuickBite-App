//
//  HelpSupportView.swift
//  QuickBite App
//
//  Created by jessica tedja on 04/11/25.
//

import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    private let brandOrange = Color(red: 1.0, green: 0.584, blue: 0.0)

    @State private var subject: String = ""
    @State private var message: String = ""

    @State private var showThanks = false

    private var canSend: Bool {
        subject.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4 &&
        message.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    ContactSupportCard(brandOrange: brandOrange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Send us a message")
                            .font(.subheadline.weight(.semibold))
                        Text("Describe your issue and we’ll get back to you as soon as possible")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Subject")
                            .font(.footnote.weight(.semibold))
                        RoundedTextField(
                            placeholder: "Brief description of your issue",
                            text: $subject
                        )
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Message")
                            .font(.footnote.weight(.semibold))
                        RoundedTextEditor(
                            placeholder: "Describe your issue in detail...",
                            text: $message,
                            minHeight: 120
                        )
                    }
                    
                    Button {
                        hideKeyboard()
                        withAnimation(.easeInOut(duration: 0.22)) {
                            showThanks = true
                        }
                        subject = ""
                        message = ""
                    } label: {
                        Text("Send Message")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(canSend ? Color.orange : Color(.systemGray4))
                            .cornerRadius(24)
                        
                    }
                    .disabled(!canSend)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                    
                if showThanks {
                    ThanksAlertView(
                        brandOrange: brandOrange,
                        onClose: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                showThanks = false
                            }
                        }
                    )
                    .animation(.easeInOut(duration: 0.25), value: showThanks)
                    .zIndex(10)
                }
            }
        }
        .navigationTitle("Help & Support")
    }
}

private struct ContactSupportCard: View {
    let brandOrange: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(brandOrange)
                Text("Contact Support")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            Text("Our support team is available 24/7 to help you")
                .font(.footnote)
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.secondary)
                    Text("Email : ")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text("customerservice@quickbite.com")
                        .font(.footnote)
                        .foregroundColor(.blue)
                    Spacer()
                }

                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.secondary)
                    Text("Phone: ")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text("(+62)12345679123")
                        .font(.footnote)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.06), lineWidth: 0.8)
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(brandOrange.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(brandOrange.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct RoundedTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
            )
    }
}

private struct RoundedTextEditor: View {
    var placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 100

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            TextEditor(text: $text)
                .font(.footnote)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .frame(minHeight: minHeight)
                .background(Color.clear)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.08), lineWidth: 0.8)
        )
    }
}

private struct ThanksAlertView: View {
    let brandOrange: Color
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 12) {
                Text("Thanks for Your Message")
                    .font(.headline)

                Text("Your message has been submitted. Our support team will review it and get back to you shortly.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)

                Button {
                    onClose()
                } label: {
                    Text("Close")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(brandOrange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.2), radius: 18, y: 8)
            .padding(.horizontal, 36)
            .transition(.scale.combined(with: .opacity))
        }
        .zIndex(999)
    }
}
