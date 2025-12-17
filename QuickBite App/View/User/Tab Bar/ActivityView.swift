//
//  ActivityView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct ActivityView: View {

    // MARK: - ENVIRONMENT
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var navState: AppNavigationState

    // MARK: - STATIC USER ID
    private let userId = "GPPxfTRmwlfr1hkmVKvSVI9Kvtk1"
    
    // MARK: - VIEW MODEL
    @StateObject private var vm = ActivityViewModel()

    // MARK: - UI STATE
    @State private var selectedTab = 0
    @State private var goToPickUpView = false
    @State private var selectedOrderId: String?

    @State private var showReviewView = false
    @State private var selectedOrderIndex: Int?
    @State private var tempRating: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // ================= HEADER =================
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity")
                        .font(.title)
                        .fontWeight(.bold)

                    Picker("", selection: $selectedTab) {
                        Text("In Progress").tag(0)
                        Text("History").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                // ================= CONTENT =================
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        if selectedTab == 0 {
                            // ================= IN PROGRESS =================
                            if vm.progressOrders.isEmpty {
                                emptyState("No ongoing orders")
                            }

                            ForEach(vm.progressOrders) { order in
                                VStack(spacing: 12) {
                                    headerRow(
                                        date: order.formattedDate,
                                        status: order.status.capitalized,
                                        color: statusColor(for: order.status)
                                    )

                                    orderCard(
                                        order: order,
                                        actionTitle: "Track Order",
                                        actionEnabled: true
                                    ) {
                                        selectedOrderId = order.id
                                        goToPickUpView = true
                                    }
                                }
                                .cardStyle()
                            }
                        } else {
                            // ================= HISTORY =================
                            if vm.historyOrders.isEmpty {
                                emptyState("No completed orders yet")
                            }

                            // PERBAIKAN: Menggunakan enumerated untuk mendapatkan index yang valid
                            ForEach(Array(vm.historyOrders.enumerated()), id: \.element.id) { index, order in
                                VStack(spacing: 12) {
                                    headerRow(
                                        date: order.formattedDate,
                                        status: "Completed",
                                        color: .green
                                    )

                                    orderCard(
                                        order: order,
                                        actionTitle: "Buy Again",
                                        actionEnabled: false,
                                        action: {}
                                    )

                                    if order.rating == nil {
                                        Divider()
                                        // Memanggil ratingRow dengan index dari enumerated
                                        ratingRow(index: index)
                                    } else {
                                        // Opsional: Tampilkan rating jika sudah dinilai
                                        HStack {
                                            Text("Your Rating")
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                Text("\(order.rating ?? 0)")
                                            }
                                            .foregroundColor(.orange)
                                        }
                                        .font(.caption)
                                    }
                                }
                                .cardStyle()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            // ================= NAVIGATION =================
            .navigationDestination(isPresented: $goToPickUpView) {
                if let id = selectedOrderId {
                    OrderPreparedView(orderId: id)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .navigationDestination(isPresented: $showReviewView) {
                if let idx = selectedOrderIndex, vm.historyOrders.indices.contains(idx) {
                    ReviewView(
                        rating: Binding(
                            get: { tempRating },
                            set: { tempRating = $0 }
                        ),
                        didSubmit: .constant(false),
                        onSubmit: { rating in
                            // Simpan ke Firestore via ViewModel
                            if let orderId = vm.historyOrders[idx].id {
                                vm.updateRating(orderId: orderId, rating: rating)
                            }
                        }
                    )
                }
            }
            .onAppear {
                vm.fetchOrders(for: userId)
            }
        }
    }

    // ================= HELPERS (PERBAIKAN) =================
    
    private func ratingRow(index: Int) -> some View {
        HStack {
            Text("Give us rating!")
            Spacer()
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: "star.fill")
                        .foregroundColor(.gray.opacity(0.3))
                        .onTapGesture {
                            self.tempRating = star
                            self.selectedOrderIndex = index
                            self.showReviewView = true
                        }
                }
            }
        }
        .font(.subheadline)
    }

    // (Fungsi helper lainnya seperti orderCard, restaurantImage, dll tetap sama dengan kode Anda)
    // ... paste fungsi helper Anda di sini ...
    
    private func orderCard(order: ActivityOrderModel, actionTitle: String, actionEnabled: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            // Menggunakan URL gambar dari koleksi stores (hasil konversi gs://)
            restaurantImage(url: order.storeSearchImageURL, name: order.restaurantName)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.restaurantName ?? "Loading Store...")
                    .font(.headline)
                
                Text(order.mealName ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("Rp\(order.totalCost)")
                    .foregroundColor(.orange)
            }
            Spacer()
            Button(action: action) {
                Text(actionTitle)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            .disabled(!actionEnabled)
        }
    }

    private func restaurantImage(url: String?, name: String?) -> some View {
        ZStack {
            if let urlString = url, let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        // Saat URL ada tapi proses download sedang berjalan
                        ProgressView()
                            .tint(.orange)
                    case .success(let image):
                        // Saat gambar berhasil di-load
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        // Saat download gagal
                        placeholderInitial(name)
                    @unknown default:
                        placeholderInitial(name)
                    }
                }
            } else {
                // Saat URL masih nil (ViewModel masih memproses gs:// ke HTTPS)
                VStack(spacing: 4) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.orange)
                }
            }
        }
        .frame(width: 56, height: 56)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func placeholderInitial(_ name: String?) -> some View {
        Text(name?.prefix(1).uppercased() ?? "?").font(.headline).foregroundColor(.orange)
    }

    private func headerRow(date: String, status: String, color: Color) -> some View {
        HStack {
            Text(date).foregroundColor(.gray)
            Spacer()
            Text(status).foregroundColor(color)
        }
        .font(.caption)
    }

    private func emptyState(_ text: String) -> some View {
        Text(text).foregroundColor(.gray).padding(.top, 40)
    }

    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "ready", "completed": return .green
        default: return .orange
        }
    }
}

// ================= CARD STYLE =================
private extension View {
    func cardStyle() -> some View {
        self.padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2)))
    }
}
