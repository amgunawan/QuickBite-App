//
//  ImageResizeHelper.swift
//  QuickBite
//
//  Created by jessica tedja on 17/12/25.
//

import UIKit

enum ImageResizeMode {
    case square
    case ratio16x9
}

struct ImageResizeHelper {

    static func resize(
        _ image: UIImage,
        mode: ImageResizeMode,
        maxSize: CGFloat = 1200
    ) -> UIImage {

        let targetRatio: CGFloat = {
            switch mode {
            case .square: return 1
            case .ratio16x9: return 16 / 9
            }
        }()

        let originalSize = image.size
        let originalRatio = originalSize.width / originalSize.height

        var cropRect: CGRect

        if originalRatio > targetRatio {
            // Image is too wide → crop width
            let newWidth = originalSize.height * targetRatio
            let xOffset = (originalSize.width - newWidth) / 2
            cropRect = CGRect(
                x: xOffset,
                y: 0,
                width: newWidth,
                height: originalSize.height
            )
        } else {
            // Image is too tall → crop height
            let newHeight = originalSize.width / targetRatio
            let yOffset = (originalSize.height - newHeight) / 2
            cropRect = CGRect(
                x: 0,
                y: yOffset,
                width: originalSize.width,
                height: newHeight
            )
        }

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        let cropped = UIImage(cgImage: cgImage)

        // Resize down if needed
        let scale = min(
            maxSize / cropped.size.width,
            maxSize / cropped.size.height,
            1
        )

        let newSize = CGSize(
            width: cropped.size.width * scale,
            height: cropped.size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        cropped.draw(in: CGRect(origin: .zero, size: newSize))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage ?? cropped
    }
}
