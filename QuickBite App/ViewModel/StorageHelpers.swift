//
//  StorageHelpers.swift
//  QuickBite
//
//  Created by jessica tedja on 17/12/25.
//

import UIKit
import FirebaseStorage

func uploadImageToStorage(
    _ image: UIImage,
    path: String
) async throws -> String {

    guard let data = image.jpegData(compressionQuality: 0.85) else {
        throw NSError(domain: "IMAGE", code: 500)
    }

    let ref = Storage.storage().reference().child(path)
    _ = try await ref.putDataAsync(data)

    // ✅ Return canonical storage URI
    return "gs://\(ref.bucket)/\(ref.fullPath)"
}
