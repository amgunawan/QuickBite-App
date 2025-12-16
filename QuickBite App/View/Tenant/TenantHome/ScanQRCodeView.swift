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

    @EnvironmentObject var tenantSession: TenantSession
    @Environment(\.dismiss) private var dismiss

    // MARK: - UI State
    @State private var isFlashOn = false
    @State private var isScanningEnabled = true
    @State private var goToActivity = false

    // MARK: - Order Data
    @State private var scannedOrder: OrderCardViewData? = nil
    @State private var scannedOrderId: String? = nil
    @State private var showOrderSheet = false

    // MARK: - FIRESTORE FETCH
    func handleScannedCode(_ code: String) {

        guard tenantSession.isLoaded else {
            print("⏳ Tenant session not ready")
            return
        }

        let db = Firestore.firestore()
        let orderId = code.trimmingCharacters(in: .whitespacesAndNewlines)
        scannedOrderId = orderId

        let orderRef = db.collection("orders").document(orderId)

        orderRef.getDocument { snapshot, error in
            if let error = error {
                print("🔥 Error fetch:", error.localizedDescription)
                return
            }

            guard
                let snapshot = snapshot,
                snapshot.exists,
                let data = snapshot.data()
            else {
                print("⚠️ Order not found")
                return
            }

            // 🔐 VALIDASI TENANT
            let orderTenantId = data["tenantId"] as? String ?? ""
            if orderTenantId != tenantSession.tenantId {
                print("⛔ QR NOT FOR THIS TENANT")
                return
            }

            // 🔐 VALIDASI STATUS
            let status = data["status"] as? String ?? "pending"
            if status == "completed" {
                DispatchQueue.main.async {
                    scannedOrder = OrderCardViewData(
                        name: "Order Invalid",
                        pickupTime: "-",
                        items: ["This order has already been picked up"],
                        total: "-"
                    )
                    showOrderSheet = true
                }
                return
            }

            // ✅ ORDER VALID
            let customerName = data["customerName"] as? String ?? "Unknown"
            let pickupTime  = data["pickupTime"] as? String ?? "-"
            let items       = data["items"] as? [String] ?? []
            let totalInt    = data["total"] as? Int ?? 0

            DispatchQueue.main.async {
                scannedOrder = OrderCardViewData(
                    name: customerName,
                    pickupTime: pickupTime,
                    items: items,
                    total: "Rp \(formatPrice(Double(totalInt)))"
                )
                showOrderSheet = true
                isScanningEnabled = false
            }
        }
    }

    // MARK: - LOCK ORDER (FINAL & AMAN)
    func lockOrder() {
        guard let orderId = scannedOrderId else { return }

        let db = Firestore.firestore()
        let orderRef = db.collection("orders").document(orderId)

        orderRef.updateData([
            "status": "completed",
            "completedAt": Timestamp()
        ]) { error in
            if let error = error {
                print("🔥 Failed to complete order:", error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                showOrderSheet = false
                goToActivity = true
            }
        }
    }

    private func resetScanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isScanningEnabled = true
        }
    }

    // MARK: - VIEW
    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreviewView(
                    isFlashOn: isFlashOn,
                    onQRCodeScanned: { scannedValue in
                        if isScanningEnabled {
                            handleScannedCode(scannedValue)
                        }
                    }
                )
                .ignoresSafeArea()

                VStack {

                    // TOP BAR
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.45))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Button { isFlashOn.toggle() } label: {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.45))
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
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)

            // ORDER FOUND SHEET
            .sheet(isPresented: $showOrderSheet) {
                if let order = scannedOrder {
                    OrderFoundSheet(
                        order: order,
                        onCancel: {
                            showOrderSheet = false
                            resetScanner()
                        },
                        onConfirm: {
                            lockOrder()
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
        .environmentObject(TenantSession())
}
