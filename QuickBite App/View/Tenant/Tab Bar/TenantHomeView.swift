//
//  TenantHomeView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

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
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(16)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

struct MetricCard: View {
    let metric: SummaryMetrics
    var borderColor: Color {
        switch metric.title {
        case "Total Income": return .green
        case "Total Orders": return .orange
        default: return .red
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
        .padding()
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
            ForEach(0..<5) { i in
                Image(systemName: i < Int(round(rating)) ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(Color(hex: "#FF9500"))
            }
        }
    }
}

struct LineChart: View {
    let points: [DaySalesPoint]
    var maxValue: Double { max(points.map { $0.value }.max() ?? 1, 1) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let stepX = w / CGFloat(max(points.count - 1, 1))
            let scaled = points.enumerated().map { (i, p) -> CGPoint in
                CGPoint(x: CGFloat(i) * stepX, y: h - CGFloat(p.value / maxValue) * h)
            }

            ZStack(alignment: .bottomLeading) {
                // Garis tren
                Path { path in
                    guard let first = scaled.first else { return }
                    path.move(to: first)
                    scaled.dropFirst().forEach { path.addLine(to: $0) }
                }
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineJoin: .round))

                // Titik data & label X
                ForEach(Array(points.enumerated()), id: \.offset) { i, p in
                    let pt = scaled[i]
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)
                        .position(pt)
                    Text(p.day)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .position(x: pt.x, y: h + 8)
                }

                // Sumbu Y (Rp)
                VStack(alignment: .leading, spacing: h / 4) {
                    ForEach((0...4).reversed(), id: \.self) { i in
                        Text("Rp\(Int(maxValue) * i / 4)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .frame(height: 160)
    }
}

struct BarChart: View {
    let items: [HourBucket]
    var maxVal: Int { max(items.map { $0.count }.max() ?? 1, 1) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(items) { b in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [Color(hex: "#FF9500"), Color.orange.opacity(0.8)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 24, height: CGFloat(b.count) / CGFloat(maxVal) * 120)
                    Text("\(b.hour)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 150)
    }
}

//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
//        _ = scanner.scanString("#")
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//        let r = Double((rgb >> 16) & 0xFF) / 255
//        let g = Double((rgb >> 8) & 0xFF) / 255
//        let b = Double(rgb & 0xFF) / 255
//        self.init(red: r, green: g, blue: b)
//    }
//}

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
        .init(index: 3, name: "Katsutama Donburi", left: 0)
    ]

    // Busy Hours
    @State private var busiestHours: [HourBucket] = [
        .init(hour: 10, count: 8),
        .init(hour: 11, count: 12),
        .init(hour: 12, count: 15),
        .init(hour: 1, count: 9),
        .init(hour: 2, count: 7),
        .init(hour: 3, count: 8),
        .init(hour: 4, count: 10),
        .init(hour: 5, count: 9)
    ]

    // Ratings
    @State private var ratingScore: Double = 4.8
    @State private var totalReviews: Int = 27

    var formattedBalance: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = "."
        return "Rp " + (nf.string(from: NSNumber(value: walletBalance)) ?? "0")
    }

    var formattedScheduled: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        return df.string(from: scheduledDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    Card {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome, \(tenantName)!")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("It's a great day to serve delicious bites!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image("Raburi")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                        }
                    }

                    // Performance Overview
                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Performance Overview")
                                .font(.headline)
                            HStack(spacing: 12) {
                                MetricCard(metric: SummaryMetrics(title: "Total Income", value: "Rp \(Int(totalIncome))", subtitle: "↑ 1.3% Up from yesterday", icon: "creditcard"))
                                MetricCard(metric: SummaryMetrics(title: "Total Orders", value: "\(totalOrders) orders", subtitle: "↑ 4.3% Up from yesterday", icon: "cart"))
                                MetricCard(metric: SummaryMetrics(title: "Pending Pickups", value: "\(pendingPickups) orders", subtitle: "", icon: "clock"))
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

                    // Wallet (Orange Card Directly)
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "#FF9500"))
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Total Wallet Balance")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "creditcard")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(6)
                                    .background(Color.white.opacity(0.25))
                                    .clipShape(Circle())
                            }
                            Text(formattedBalance)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Divider().background(Color.white.opacity(0.7))
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
                        .padding(16)
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
                                    .foregroundColor(Color(hex: "#FF9500"))
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
                            Text("Top 3 Menu Items").font(.headline)
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
                            Text("Order Busiest Hours Heatmap").font(.headline)
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
                .padding(.top, 8)
            }
            .navigationDestination(isPresented: $showAllReviews) {
                AllReviewsTenantView()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
        }
    }
}

// Helper
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

#Preview {
    TenantHomeView()
}
