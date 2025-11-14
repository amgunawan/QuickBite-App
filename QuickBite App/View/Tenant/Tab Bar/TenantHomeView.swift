//
//  TenantHomeView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

// MARK: - Design Tokens
private enum UIConst {
    static let corner: CGFloat = 16
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
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    HeaderBackgroundView(height: 160)
                        .frame(height: 52)
                        .ignoresSafeArea(edges: .top)
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            Text("Home")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                                        .frame(width: 62, height: 62)
                                        .cornerRadius(8)
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                        
                        VStack(spacing: 10) {
                            // Button Scan QR Code
                            Button(action: {}) {
                                HStack {
                                    Text("Scan Order QR")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.green)
                                .cornerRadius(UIConst.corner)
                            }
                            
                            // Wallet Card
                            ZStack {
                                RoundedRectangle(cornerRadius: UIConst.corner)
                                    .fill(UIConst.brandOrange)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Total Wallet Balance")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(formattedBalance)
                                        .font(.title2).fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Divider().frame(height: 1).background(Color.white)
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
                            }
                            
                            // Performance Overview
                            Card {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Today's Performance Overview")
                                        .font(.headline)
                                    HStack(spacing: 6) {
                                        MetricCard(metric: .init(title: "Total Income",
                                                                 value: "Rp \(Int(totalIncome))",
                                                                 subtitle: "↑ 1.3% Up from yesterday",
                                                                 icon: "creditcard"))
                                        MetricCard(metric: .init(title: "Total Orders",
                                                                 value: "\(totalOrders) orders",
                                                                 subtitle: "↑ 4.3% Up from yesterday",
                                                                 icon: "cart"))
                                        MetricCard(metric: .init(title: "Pending Orders",
                                                                 value: "\(pendingPickups) orders",
                                                                 subtitle: "",
                                                                 icon: "clock"))
                                    }
                                }
                            }
                            
                            // Weekly Sales
                            Card {
                                LineChart(points: weeklySales)
                            }
                            
                            // Rating
                            Card {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("Customer Rating")
                                            .font(.headline)
                                        Spacer()
                                        Button("See All") { showAllReviews = true }
                                            .font(.subheadline)
                                    }
                                    HStack(spacing: 5) {
                                        Text(String(format: "%.1f", ratingScore))
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(UIConst.brandOrange)
                                        Text("/ 5")
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                    }
                                    Text("(Based on \(totalReviews) reviews)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    RatingStars(rating: ratingScore, size: 25)
                                }
                            }
                            
                            // Top 3 Menu
                            Card {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Top 3 Menu Items")
                                        .font(.headline)
                                    HStack {
                                        Text("No").frame(width: 30).foregroundColor(UIConst.brandOrange)
                                        Text("Menu").frame(maxWidth: .infinity, alignment: .leading).foregroundColor(UIConst.brandOrange)
                                        Text("Sold").frame(width: 50, alignment: .trailing).foregroundColor(UIConst.brandOrange)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    Divider()
                                    ForEach(topMenu) { item in
                                        HStack {
                                            Text("\(item.index).").frame(width: 30).font(.footnote)
                                            Text(item.name).frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.footnote)
                                            Text("\(item.sold)").font(.footnote).frame(width: 50, alignment: .trailing)
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
                                        Text("No").frame(width: 30).foregroundColor(UIConst.brandOrange)
                                        Text("Menu").frame(maxWidth: .infinity, alignment: .leading).foregroundColor(UIConst.brandOrange)
                                        Text("Stock Left").frame(width: 80, alignment: .trailing).foregroundColor(UIConst.brandOrange)
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    Divider()
                                    ForEach(lowStock) { s in
                                        HStack {
                                            Text("\(s.index).").frame(width: 30).font(.footnote)
                                            Text(s.name).frame(maxWidth: .infinity, alignment: .leading).font(.footnote)
                                            Text("\(s.left)").frame(width: 80, alignment: .trailing).font(.footnote)
                                        }
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationDestination(isPresented: $showAllReviews) {
                AllReviewsTenantView()
            }
            
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
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
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
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
        VStack(spacing: 8) {
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(borderColor.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: metric.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(borderColor)
                }
                Spacer()
            }
            
            VStack(alignment: .center, spacing: 6) {
                HStack(spacing: 6) {
                    Text(metric.title)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Text(metric.value)
                    .font(.headline).fontWeight(.semibold)
                //                if !metric.subtitle.isEmpty {
                //                    Text(metric.subtitle)
                //                        .font(.caption)
                //                        .foregroundColor(.green)
                //                }
            }
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
        .frame(minHeight: 110)
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

// MARK: - LineChart
struct LineChart: View {
    let points: [DaySalesPoint]
    @State private var hoveredPoint: DaySalesPoint? = nil
    
    private var maxValue: Double {
        guard let max = points.map(\.value).max() else { return 1 }
        return max == 0 ? 1 : max
    }
    
    // MARK: - Currency Formatter
    private var currencyFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = "."
        nf.maximumFractionDigits = 0
        return nf
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Title
            Text("Weekly Performance Sales Trends")
                .font(.headline)
                .padding(.bottom, 1)
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("Up 12% compared to last week")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            // MARK: - Chart
            GeometryReader { geo in
                let chartWidth = geo.size.width - 70   // give space for y-axis
                let chartHeight = geo.size.height - 30 // keep Rp0 visible
                let stepX = chartWidth / CGFloat(points.count-1)
                
                let scaledPoints = points.enumerated().map { i, p in
                    CGPoint(
                        x: CGFloat(i) * stepX,
                        y: chartHeight - CGFloat(p.value / maxValue) * (chartHeight)
                    )
                }
                
                HStack(alignment: .top, spacing: 5) {
                    // MARK: - Y Axis
                    VStack(alignment: .trailing, spacing: chartHeight / 8) {
                        ForEach((0...4).reversed(), id: \.self) { i in
                            let value = maxValue / 4 * Double(i)
                            Text("Rp\(currencyFormatter.string(from: NSNumber(value: value)) ?? "0")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 60)
                    
                    // MARK: - Chart Body
                    ZStack(alignment: .bottomLeading) {
                        // Line Path
                        Path { path in
                            guard let first = scaledPoints.first else { return }
                            path.move(to: first)
                            scaledPoints.dropFirst().forEach { path.addLine(to: $0) }
                        }
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
                        
                        // Dots + Tooltip
                        ForEach(Array(points.enumerated()), id: \.offset) { i, p in
                            let pt = scaledPoints[i]
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 7, height: 7)
                                .position(pt)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        hoveredPoint = hoveredPoint?.id == p.id ? nil : p
                                    }
                                }
                            
                            // Tooltip bubble
                            if hoveredPoint?.id == p.id {
                                VStack(spacing: 4) {
                                    Text("Rp \(currencyFormatter.string(from: NSNumber(value: p.value)) ?? "0")")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .padding(6)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.orange.opacity(0.4), lineWidth: 0.8)
                                        )
                                        .shadow(radius: 2)
                                    Triangle()
                                        .fill(Color.white)
                                        .frame(width: 8, height: 5)
                                }
                                .position(x: pt.x, y: pt.y - 25)
                            }
                        }
                        
                        // X Axis Labels
                        HStack(spacing: 5) {
                            ForEach(points) { p in
                                Text(p.day)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .frame(width: chartWidth)
                }
            }
            .frame(height: 200)
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }
}

// MARK: - Triangle (Tooltip Pointer)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Mark: BarChart
struct BarChart: View {
    let items: [HourBucket]
    private var maxVal: Int {
        guard let max = items.map(\.count).max() else { return 1 }
        return max == 0 ? 1 : max
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(items) { b in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#FFB84D"),
                                        UIConst.brandOrange
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: 32,
                                height: CGFloat(b.count) / CGFloat(maxVal) * 120
                            )
                        Text("\(b.hour)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Text("10 AM")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("5 PM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .frame(height: 160)
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
