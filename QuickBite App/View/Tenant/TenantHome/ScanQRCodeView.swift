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

    @EnvironmentObject var authVM: AuthenticationViewModel
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

        // ✅ ENSURE USER SESSION EXISTS
        guard let session = authVM.currentUserSession else {
            print("⏳ User session not ready")
            return
        }

        // ✅ ENSURE THIS USER HAS A STORE (TENANT)
        guard let tenantId = session.storeId else {
            print("⛔ User is not a tenant / has no store")
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
                let document = snapshot,
                document.exists,
                let data = document.data()
            else {
                print("⚠️ Order not found")
                return
            }

            // 🔐 TENANT VALIDATION
            let orderTenantId = data["tenantId"] as? String ?? ""
            if orderTenantId != tenantId {
                print("⛔ QR NOT FOR THIS TENANT")
                return
            }

            // 🔐 STATUS VALIDATION
            let status = data["status"] as? String ?? "pending"

            guard status == "ready_for_pickup" else {
                DispatchQueue.main.async {
                    scannedOrder = OrderCardViewData(
                        id: orderId,
                        name: "Order Invalid",
                        pickupTime: "-",
                        items: ["Order status is '\(status)'. Only READY orders can be scanned."],
                        total: "-",
                        status: status
                    )
                    showOrderSheet = true
                }
                return
            }

            // ✅ ORDER VALID
            let customerName = data["customerName"] as? String ?? "Unknown"
            let pickupTime  = (data["pickup_time"] as? Timestamp)?.dateValue()
            let itemsRaw    = data["items"] as? [[String: Any]] ?? []
            let totalInt    = data["total_cost"] as? Int ?? 0

            let itemNames = itemsRaw.compactMap { $0["item_id"] as? String }

            DispatchQueue.main.async {
                scannedOrder = OrderCardViewData(
                    id: orderId,
                    name: customerName,
                    pickupTime: formatTime(pickupTime),
                    items: itemNames,
                    total: "Rp \(formatPrice(Double(totalInt)))",
                    status: "ready_for_pickup"
                )
                showOrderSheet = true
                isScanningEnabled = false
            }

        }

    }

    // MARK: - LOCK ORDER
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
