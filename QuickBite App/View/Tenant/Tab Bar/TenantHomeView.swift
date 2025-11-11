//
//  TenantHomeView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

// MARK: - Design Tokens
private enum UIConst {
    static let corner: CGFloat = 14
    static let pad: CGFloat = 16
    static let brandOrange = Color(hex: "#FF9500")
    static let softCardBG  = Color.white
    static let hairline    = Color(.systemGray5)
}

// MARK: - Models
struct SummaryMetrics: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let icon: String
}

struct DaySalesPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

struct MenuItemSold: Identifiable {
    let id = UUID()
    let index: Int
    let name: String
    let sold: Int
}

struct HourBucket: Identifiable {
    let id = UUID()
    let hour: Int
    let count: Int
}

struct StockItem: Identifiable {
    let id = UUID()
    let index: Int
    let name: String
    let left: Int
}

// MARK: - Components
struct Card<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        content()
            .padding(UIConst.pad)
            .background(UIConst.softCardBG)
            .overlay(
                RoundedRectangle(cornerRadius: UIConst.corner)
                    .stroke(UIConst.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: UIConst.corner))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct MetricCard: View {
    let metric: SummaryMetrics

    private var borderColor: Color {
        switch metric.title {
        case "Total Income": return .green
        case "Total Orders": return .orange
        default:             return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: metric.icon)
                    .foregroundColor(borderColor)
                Text(metric.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(metric.value)
                .font(.headline)
            if !metric.subtitle.isEmpty {
                Text(metric.subtitle)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor.opacity(0.5), lineWidth: 1)
        )
    }
}

struct RatingStars: View {
    let rating: Double
    let size: CGFloat
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < Int(round(rating)) ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(UIConst.brandOrange)
            }
        }
    }
}

struct LineChart: View {
    let points: [DaySalesPoint]
    private var maxValue: Double { max(points.map(\.value).max() ?? 1, 1) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let stepX = w / CGFloat(max(points.count - 1, 1))
            let scaled: [CGPoint] = points.enumerated().map { i, p in
                CGPoint(x: CGFloat(i) * stepX, y: h - CGFloat(p.value / maxValue) * h)
            }

            ZStack(alignment: .bottomLeading) {
                Path { path in
                    guard let first = scaled.first else { return }
                    path.move(to: first)
                    scaled.dropFirst().forEach { path.addLine(to: $0) }
                }
                .stroke(UIConst.brandOrange, style: .init(lineWidth: 2, lineJoin: .round))

                ForEach(Array(points.enumerated()), id: \.offset) { i, p in
                    let pt = scaled[i]
                    Circle()
                        .fill(UIConst.brandOrange)
                        .frame(width: 6, height: 6)
                        .position(pt)
                    Text(p.day)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .position(x: pt.x, y: h + 8)
                }
            }
        }
        .frame(height: 150)
    }
}

struct BarChart: View {
    let items: [HourBucket]
    private var maxVal: Int { max(items.map(\.count).max() ?? 1, 1) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(items) { b in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [UIConst.brandOrange, .orange.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 22, height: CGFloat(b.count) / CGFloat(maxVal) * 120)
                    Text("\(b.hour)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 150)
    }
}

struct HomeSettingsRowLabel: View {
    let systemIcon: String
    let tint: Color
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                Image(systemName: systemIcon)
                    .foregroundColor(tint)
                    .font(.subheadline)
            }
            .frame(width: 28, height: 28)

            Text(title)
                .foregroundColor(.primary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Header Background (inline, pengganti ProfileHeaderBackground)
private struct HomeHeaderBackgroundView: View {
    var height: CGFloat = 120
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.80, blue: 0.45),
                    Color(red: 1.00, green: 0.60, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.18))
                .frame(width: 180, height: height * 1.1)
                .rotationEffect(.degrees(10))
                .offset(x: 60, y: 10)
        }
        .frame(height: height)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - TenantHomeView
struct TenantHomeView: View {
    @State private var showAllReviews = false
    @State private var tenantName: String = "Raburi"

    // Wallet
    @State private var walletBalance: Double = 2_500_000
    @State private var scheduledDate: Date = Calendar.current.date(
        byAdding: .month,
        value: 1,
        to: Calendar.current.startOfMonth(for: Date())
    ) ?? Date()

    // Dashboard Stats
    @State private var totalIncome: Double = 325_000
    @State private var totalOrders: Int = 10
    @State private var pendingPickups: Int = 2

    // Trends
    @State private var weeklySales: [DaySalesPoint] = [
        .init(day: "Mon", value: 60_000),
        .init(day: "Tue", value: 220_000),
        .init(day: "Wed", value: 180_000),
        .init(day: "Thu", value: 320_000),
        .init(day: "Fri", value: 200_000),
        .init(day: "Sat", value: 260_000)
    ]

    // Menu + Stocks
    @State private var topMenu: [MenuItemSold] = [
        .init(index: 1, name: "Chicken Katsu Shiokara Ramen", sold: 22),
        .init(index: 2, name: "Chicken Katsu Curry Rice", sold: 14),
        .init(index: 3, name: "Katsutama Donburi", sold: 8)
    ]

    @State private var lowStock: [StockItem] = [
        .init(index: 1, name: "Chicken Katsu Shiokara Ramen", left: 4),
        .init(index: 2, name: "Chicken Katsu Curry Rice", left: 3),
        .init(index: 3, name: "Katsutama Donbri", left: 0)
    ]

    // Busy Hours
    @State private var busiestHours: [HourBucket] = [
        .init(hour: 10, count: 8),
        .init(hour: 11, count: 12),
        .init(hour: 12, count: 15),
        .init(hour: 1,  count: 9),
        .init(hour: 2,  count: 7),
        .init(hour: 3,  count: 8),
        .init(hour: 4,  count: 10),
        .init(hour: 5,  count: 9)
    ]

    // Ratings
    @State private var ratingScore: Double = 4.8
    @State private var totalReviews: Int = 27

    // Formatter
    private var formattedBalance: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = "."
        return "Rp " + (nf.string(from: walletBalance as NSNumber) ?? "0")
    }

    private var formattedScheduled: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        return df.string(from: scheduledDate)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    HeaderBackgroundView(height: 100)
                    Spacer()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Header Card
                        Card {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome, \(tenantName)!")
                                        .font(.title3).fontWeight(.bold)
                                    Text("It's a great day to serve delicious bites!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image("Raburi")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                                    .accessibilityHidden(true)
                            }
                        }

                        // Performance Overview
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Performance Overview")
                                    .font(.headline)
                                HStack(spacing: 12) {
                                    MetricCard(metric: .init(title: "Total Income",
                                                             value: "Rp \(Int(totalIncome))",
                                                             subtitle: "↑ 1.3% Up from yesterday",
                                                             icon: "creditcard"))
                                    MetricCard(metric: .init(title: "Total Orders",
                                                             value: "\(totalOrders) orders",
                                                             subtitle: "↑ 4.3% Up from yesterday",
                                                             icon: "cart"))
                                    MetricCard(metric: .init(title: "Pending Pickups",
                                                             value: "\(pendingPickups) orders",
                                                             subtitle: "",
                                                             icon: "clock"))
                                }
                            }
                        }

                        // Weekly Sales
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Weekly Performance Sales Trends")
                                        .font(.headline)
                                    Spacer()
                                    Text("↑ Up 12% compared to last week")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                LineChart(points: weeklySales)
                            }
                        }

                        // Wallet
                        Card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Wallet Balance")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(formattedBalance)
                                    .font(.title2).fontWeight(.bold)
                                    .foregroundColor(.white)
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                    Text("Scheduled for \(formattedScheduled)")
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                Text("Transferred automatically to your registered account.")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding()
                            .background(UIConst.brandOrange)
                            .cornerRadius(UIConst.corner)
                        }

                        // Rating
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Customer Rating")
                                        .font(.headline)
                                    Spacer()
                                    Button("See All") { showAllReviews = true }
                                        .font(.subheadline)
                                }
                                HStack(spacing: 10) {
                                    Text(String(format: "%.1f", ratingScore))
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(UIConst.brandOrange)
                                    Text("/ 5")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                                RatingStars(rating: ratingScore, size: 18)
                                Text("(Based on \(totalReviews) reviews)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Top 3 Menu
                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Top 3 Menu Items")
                                    .font(.headline)
                                HStack {
                                    Text("No").frame(width: 30)
                                    Text("Menu").frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Sold").frame(width: 50, alignment: .trailing)
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                Divider()
                                ForEach(topMenu) { item in
                                    HStack {
                                        Text("\(item.index).").frame(width: 30)
                                        Text(item.name).frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(item.sold)").frame(width: 50, alignment: .trailing)
                                    }
                                    Divider()
                                }
                            }
                        }

                        // Busiest Hours
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Order Busiest Hours Heatmap")
                                    .font(.headline)
                                BarChart(items: busiestHours)
                                HStack {
                                    Text("10 AM").font(.caption).foregroundColor(.secondary)
                                    Spacer()
                                    Text("5 PM").font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }

                        // Low Stock
                        Card {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Low Stock Items").font(.headline)
                                    Spacer()
                                    Button("See All") {}
                                        .font(.subheadline)
                                }
                                HStack {
                                    Text("No").frame(width: 30)
                                    Text("Menu").frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Stock Left").frame(width: 80, alignment: .trailing)
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                Divider()
                                ForEach(lowStock) { s in
                                    HStack {
                                        Text("\(s.index).").frame(width: 30)
                                        Text(s.name).frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(s.left)").frame(width: 80, alignment: .trailing)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 120) // ruang untuk header
                    .padding(.bottom, 8)
                }
                .scrollContentBackground(.hidden)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helpers
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}

#Preview {
    TenantHomeView()
}
