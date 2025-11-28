//
//  LanguageSelectionView.swift
//  QuickBite App
//
//  Created by jessica tedja on 04/11/25.
//

import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLanguage: String

    struct Lang: Identifiable, Equatable {
        let id = UUID()
        let name: String
        let code: String
        let flag: String?
        let emoji: String?
    }

    private let options: [Lang] = [
        .init(name: "English",            code: "EN", flag: "flag_us", emoji: "🇺🇸"),
        .init(name: "Bahasa Indonesia",   code: "ID", flag: "flag_id", emoji: "🇮🇩")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(options) { opt in
                    Button {
                        selectedLanguage = opt.name
                    } label: {
                        HStack(spacing: 12) {
                            if let img = opt.flag, UIImage(named: img) != nil {
                                Image(img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 26, height: 18)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                    )
                            } else if let emoji = opt.emoji {
                                Text(emoji).font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(opt.name) (\(opt.code))")
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            Radio(isSelected: selectedLanguage == opt.name)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .scrollDisabled(true)
        }
        .navigationTitle("Change Language")
    }
}

private struct Radio: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                .frame(width: 22, height: 22)
            if isSelected {
                Circle()
                    .stroke(Color.orange, lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 10, height: 10)
                    )
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
