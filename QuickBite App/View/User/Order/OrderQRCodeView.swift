//
//  OrderQRCodeView.swift
//  QuickBite App
//
//  Created by jessica tedja on 12/12/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct OrderQRCodeView: View {

    let orderId: String
    @Environment(\.dismiss) var dismiss

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack(spacing: 24) {

            Text("Show this QR to the tenant")
                .font(.title3)
                .fontWeight(.semibold)

            Image(uiImage: generateQRCode(from: orderId))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 260)

            Text("Order ID:")
                .foregroundColor(.gray)

            Text(orderId)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 14)
            .background(Color.orange)
            .cornerRadius(30)
        }
        .padding()
        .background(Color.white)
    }

    // MARK: - QR Generator
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage,
           let cgimg = context.createCGImage(
                outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)),
                from: outputImage.extent
           ) {
            return UIImage(cgImage: cgimg)
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
