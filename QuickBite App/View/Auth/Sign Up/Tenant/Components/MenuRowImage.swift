//
//  MenuRowImage.swift
//  QuickBite
//

import SwiftUI
import FirebaseStorage

struct MenuRowImage: View {

    let imageURL: String?

    @State private var uiImage: UIImage? = nil
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))

                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            loadImage()
        }
        .onChange(of: imageURL) { _, _ in
            loadImage()
        }
    }

    private func loadImage() {
        uiImage = nil
        guard
            let imageURL,
            !imageURL.isEmpty
        else { return }

        isLoading = true

        let ref = Storage.storage().reference(forURL: imageURL)
        ref.getData(maxSize: 3 * 1024 * 1024) { data, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data,
                   let img = UIImage(data: data) {
                    self.uiImage = img
                }
            }
        }
    }
}
