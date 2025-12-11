//
//  ScanQRCodeView.swift
//  QuickBite App
//
//  Created by jessica tedja on 21/11/25.
//

import SwiftUI
import AVFoundation
import FirebaseFirestore

struct ScanQRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var isFlashOn = false
    @State private var goToActivity = false
    
    // ORDER DATA RECEIVED
    @State private var scannedOrder: OrderCardViewData? = nil
    @State private var showOrderSheet = false
    
    // MARK: - FETCH FROM FIRESTORE
    func handleScannedCode(_ code: String) {
        print("QR Detected:", code)
        
        let db = Firestore.firestore()
        let orderId = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        db.collection("orders").document(orderId).getDocument { snapshot, error in
            
            if let error = error {
                print("🔥 Error fetch:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("⚠️ Order not found")
                return
            }
            
            // Convert all Firestore fields safely into Strings
            let customerName = data["customerName"] as? String ?? "Unknown"
            let pickupTime  = data["pickupTime"] as? String ?? "-"
            let items       = data["items"] as? [String] ?? []
            let totalInt = data["total"] as? Int ?? 0
            let totalString = "Rp \(formatPrice(Double(totalInt)))"

            
            // Convert into UI model
            scannedOrder = OrderCardViewData(
                name: customerName,
                pickupTime: pickupTime,
                items: items,
                total: totalString
            )
            
            // Show sheet
            showOrderSheet = true
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                // === CAMERA PREVIEW ===
                CameraPreviewView(isFlashOn: isFlashOn) { scannedValue in
                    handleScannedCode(scannedValue)
                }
                .ignoresSafeArea()

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
                    .padding(.top, 64)

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
            .ignoresSafeArea()
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
                            // Example confirm logic
                            let customerName = order.name
                            print("Order confirmed for:", customerName)

                            showOrderSheet = false
                            goToActivity = true
                        }
                    )
                    .presentationDetents([.height(420)])
                    .presentationDragIndicator(.visible)
                }
            }

            // Navigate to Tenant Activity page
            .navigationDestination(isPresented: $goToActivity) {
                TenantActivityView()
            }
        }
    }
}

#Preview {
    ScanQRCodeView()
}
