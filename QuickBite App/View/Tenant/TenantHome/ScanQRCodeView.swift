//
//  ScanQRCodeView.swift
//  QuickBite App
//
//  Created by jessica tedja on 21/11/25.
//

import SwiftUI
import AVFoundation

struct ScanQRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isFlashOn = false
    @State private var goToActivity = false     // Trigger navigate

    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreviewView(isFlashOn: isFlashOn) { scannedValue in
                    print("QR Detected: \(scannedValue)")
                    goToActivity = true
                }
                .ignoresSafeArea()

                VStack {
                    // Top bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Button(action: { isFlashOn.toggle() }) {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    Text("Scan Order QR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 12)

                    Spacer()

                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 280, height: 280)
                        .padding(.bottom, 120)

                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)    // Hide tab bar di halaman scan

            // === Navigate ke halaman Activity ===
            .navigationDestination(isPresented: $goToActivity) {
                TenantActivityView()     // <-- Langsung ke Activity (Sementara nanti harusnya ke History dan lgsg status jd complete)
            }
        }
    }
}

#Preview {
    ScanQRCodeView()
}
