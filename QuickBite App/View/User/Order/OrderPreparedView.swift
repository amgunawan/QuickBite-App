//
//  OrderPreparedView.swift
//  QuickBite
//
//  Created by student on 13/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct OrderedItem: Identifiable {
    let id = UUID()
    let count: Int
    let name: String
}

struct OrderPreparedView: View {

    var orderId: String

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    @State private var items: [OrderedItem] = []
    @State private var orderStatus: String = "pending"
    @State private var orderNumber: String = "-"
    @State private var orderDate: String = "-"
    @State private var qrImage: UIImage?

    @State private var orderTotal: Double = 0
    @State private var discount: Double = 0
    @State private var serviceFee: Double = 2500
    @State private var paymentMethod: String = "BCA"

    // MARK: - RESTAURANT STATE
    @State private var restaurantId: String = ""
    @State private var restaurantName: String = "Restaurant"
    @State private var restaurantImageURL: URL?

    @State private var rating: Double = 0
    @State private var reviewCount: Int = 0
    @State private var estTime: String = "10–20 min"

    // 🔥 FINAL CUISINE
    @State private var cuisineText: String = "-"

    // MARK: - COMPUTED
    private var totalMealCount: Int {
        items.reduce(0) { $0 + $1.count }
    }

    private var subtotal: Double {
        max(0, orderTotal - serviceFee + discount)
    }

    private var total: Double {
        max(0, orderTotal)
    }

    // ======================
    // ✅ STATUS COMPUTED
    // ======================
    private var statusTitle: String {
        switch orderStatus {
        case "ready":
            return "Order Ready for Pickup"
        case "completed":
            return "Order Completed"
        default:
            return "Order in Preparation"
        }
    }

    private var statusColor: Color {
        switch orderStatus {
        case "ready":
            return .green
        case "completed":
            return .gray
        default:
            return .orange
        }
    }

    private var statusDescription: String {
        switch orderStatus {
        case "ready":
            return "Show this QR code to the tenant."
        case "completed":
            return "This order has been completed."
        default:
            return "The restaurant is preparing your order.\nThe QR code will appear when it’s ready."
        }
    }

    // MARK: - LISTENER
    private func listenOrder() {
        db.collection("orders")
            .document(orderId)
            .addSnapshotListener { snapshot, _ in
                guard let snapshot,
                      let data = snapshot.data() else { return }

                DispatchQueue.main.async {

                    self.orderNumber = self.orderId
                    self.orderStatus = (data["status"] as? String ?? "pending").lowercased()

                    // ORDER DATE
                    if let ts = data["created_at"] as? Timestamp {
                        self.orderDate = formatOrderDate(ts.dateValue())
                    } else if let ts = data["createdAt"] as? Timestamp {
                        self.orderDate = formatOrderDate(ts.dateValue())
                    } else if snapshot.metadata.hasPendingWrites {
                        self.orderDate = formatOrderDate(Date())
                    }

                    // ITEMS
                    let rawItems = data["items"] as? [[String: Any]] ?? []
                    self.items = rawItems.compactMap {
                        guard let qty = $0["quantity"] as? Int else { return nil }

                        return OrderedItem(
                            count: qty,
                            name: ""
                        )
                    }

                    // PAYMENT
                    self.orderTotal = Double(data["total"] as? Int ?? 0)
                    self.discount = Double(data["discount"] as? Int ?? 0)
                    self.serviceFee = Double(data["serviceFee"] as? Int ?? 2500)
                    self.paymentMethod = data["paymentMethod"] as? String ?? "BCA"

                    // RESTAURANT
                    if let tenantId = data["tenantId"] as? String,
                       self.restaurantId.isEmpty {
                        self.restaurantId = tenantId
                        fetchRestaurantInfo(tenantId)
                    }

                    // 🔥 QR LOGIC (READY & COMPLETED)
                    if self.orderStatus == "ready" || self.orderStatus == "completed" {
                        if self.qrImage == nil {
                            self.qrImage = QRGenerator().generate(from: self.orderId)
                        }
                    } else {
                        self.qrImage = nil
                    }
                }
            }
    }

    private func fetchRestaurantInfo(_ id: String) {
        db.collection("stores")
            .document(id)
            .getDocument { snapshot, _ in
                guard let data = snapshot?.data() else { return }

                DispatchQueue.main.async {
                    self.restaurantName =
                        data["name"] as? String
                        ?? data["store_name"] as? String
                        ?? "Restaurant"

                    self.rating = data["rating"] as? Double ?? 0
                    self.reviewCount = data["review_count"] as? Int ?? 0

                    if let cuisines = data["cuisine_type"] as? [String] {
                        self.cuisineText = cuisines.joined(separator: ", ")
                    } else if let cuisine = data["cuisine_type"] as? String {
                        self.cuisineText = cuisine
                    } else {
                        self.cuisineText = "-"
                    }
                }

                if let path = data["search_url"] as? String {
                    let ref = storage.reference(forURL: path)
                    ref.downloadURL { url, _ in
                        DispatchQueue.main.async {
                            self.restaurantImageURL = url
                        }
                    }
                }
            }
    }

    private func formatOrderDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE MMM dd, yyyy hh:mm a"
        f.locale = Locale(identifier: "en_US")
        f.timeZone = TimeZone.current
        return f.string(from: date)
    }

    // ======================
    // BODY (UI — TIDAK DIUBAH)
    // ======================
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {

                // HEADER
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalMealCount) meal to pick up")
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("Expires on -")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                sectionDivider()

                // ORDER DETAILS
                VStack(alignment: .leading, spacing: 6) {
                    Text("Order Details")
                        .font(.subheadline)

                    ForEach(items) { item in
                        HStack {
                            Text("\(item.count)x")
                            Text(item.name)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)

                sectionDivider()

                // STATUS & QR
                VStack(spacing: 16) {

                    Text(statusTitle)
                        .font(.headline)
                        .foregroundColor(statusColor)
                        .multilineTextAlignment(.center)

                    ZStack {
                        if orderStatus == "pending" || orderStatus == "preparing" {
                            Image("Pending")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                        }

                        if (orderStatus == "ready" || orderStatus == "completed"),
                           let qrImage {
                            Image(uiImage: qrImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Text(statusDescription)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                sectionDivider()

                // RESTAURANT INFO
                VStack(alignment: .leading) {
                    Text("Restaurant Info")

                    HStack(spacing: 12) {
                        if let url = restaurantImageURL {
                            AsyncImage(url: url) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 62, height: 62)
                            .cornerRadius(8)
                        } else {
                            Color.gray.opacity(0.3)
                                .frame(width: 62, height: 62)
                                .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurantName)
                                .font(.headline)

                            Text(cuisineText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("⭐ \(String(format: "%.1f", rating)) (\(reviewCount)) • \(estTime)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)

                sectionDivider()

                // SUMMARY
                VStack(alignment: .leading, spacing: 6) {
                    Text("Order Summary")

                    SummaryRow(title: "Quantity", value: "\(totalMealCount)")
                    SummaryRow(title: "Subtotal", value: "Rp\(formatPrice(subtotal))")
                    SummaryRow(title: "Seller discount", value: "-Rp\(formatPrice(discount))", valueColor: .green)
                    SummaryRow(title: "Service Fee", value: "+Rp\(formatPrice(serviceFee))")
                    SummaryRow(title: "Total", value: "Rp\(formatPrice(total))", weight: .semibold)

                    Divider().padding(.vertical, 4)

                    SummaryRow(title: "Order number", value: orderNumber)
                    SummaryRow(title: "Order date", value: orderDate)
                    SummaryRow(title: "Payment method", value: paymentMethod)
                }
                .padding(.horizontal)

                Button("Buy Again") {}
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .padding()
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Order Prepared")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            listenOrder()
        }
    }

    // MARK: - UI HELPER
    private func sectionDivider() -> some View {
        Rectangle()
            .fill(Color.orange.opacity(0.25))
            .frame(height: 8)
            .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        OrderPreparedView(orderId: "I8oUxS8tW1F9wk9CIKga")
    }
}
