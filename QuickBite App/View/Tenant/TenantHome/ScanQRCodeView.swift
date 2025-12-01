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
    @State private var goToActivity = false
    
    // === SCAN RESULT ===
    @State private var scannedOrder: OrderCardViewData? = nil
    @State private var showOrderSheet = false

    // MARK: - Handle QR Result
    func handleScannedCode(_ code: String) {
        print("QR Detected: \(code)")
        
        // === SEMENTARA: Hardcoded Example ===
        if code == "AngelaMeliaQR" {
            scannedOrder = OrderCardViewData(
                name: "Angela Melia",
                pickupTime: "12:00 PM",
                items: ["1x Chicken Katsu Shirokara Ramen"],
                total: "Rp 83.000"
            )
            showOrderSheet = true
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {

                // === FULL SCREEN CAMERA ===
                CameraPreviewView(isFlashOn: isFlashOn) { scannedValue in
                    handleScannedCode(scannedValue)
                }
                .ignoresSafeArea() // <-- tetap dipakai

                // === OVERLAY UI ===
                VStack {

                    // === TOP BAR ===
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

                    // === WHITE SCAN FRAME ===
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 280, height: 280)
                        .padding(.bottom, 120)

                    Spacer()
                }
            }
            // === FIX: REMOVE WHITE BOTTOM AREA ===
            .ignoresSafeArea()    // <-- Yang paling penting, DI SINI!
            
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)

            // === BOTTOM SHEET ===
            .sheet(isPresented: $showOrderSheet) {
                if let order = scannedOrder {
                    OrderFoundSheet(
                        order: order,
                        onCancel: {
                            showOrderSheet = false
                        },
                        onConfirm: {
                            showOrderSheet = false
                            goToActivity = true
                        }
                    )
                    .presentationDetents([.height(420)])
                    .presentationDragIndicator(.visible)
                }
            }

            .navigationDestination(isPresented: $goToActivity) {
                TenantActivityView()
            }
        }
    }
}

#Preview {
    ScanQRCodeView()
}
