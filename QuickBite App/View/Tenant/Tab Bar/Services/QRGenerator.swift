//
//  QRGenerator.swift
//  QuickBite App
//
//  Created by student on 03/12/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

class QRGenerator {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    func generate(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let output = filter.outputImage {
            let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
            if let cgimg = context.createCGImage(scaled, from: scaled.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle")!
    }
}
