//
//  MenuRowImage.swift
//  QuickBite
//

import SwiftUI
import FirebaseStorage

struct MenuRowImage: View {

    let imageURL: String?
    let draftImage: UIImage?

    @State private var uiImage: UIImage? = nil

    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear { resolveImage() }
        .onChange(of: imageURL) { _, _ in resolveImage() }
        .onChange(of: draftImage) { _, _ in resolveImage() }
    }

    private func resolveImage() {
        // 1️⃣ DRAFT IMAGE (highest priority)
        if let draftImage {
            uiImage = draftImage
            return
        }

        // 2️⃣ FIREBASE IMAGE
        guard let imageURL,
              imageURL.hasPrefix("gs://") || imageURL.hasPrefix("http")
        else {
            uiImage = nil
            return
        }

        let ref = Storage.storage().reference(forURL: imageURL)
        ref.getData(maxSize: 3 * 1024 * 1024) { data, _ in
            if let data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = img
                }
            }
        }
    }
}
