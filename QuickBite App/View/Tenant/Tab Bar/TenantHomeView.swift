//
//  TenantHomeView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

enum TenantHomeDestination: Hashable {
    case allReviews
    case manageStock
}

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


struct TenantHomeView: View {
    @StateObject private var totalWalletVM = TotalWalletBalanceViewModel()
    @StateObject private var todayPerformanceVM = TodayPerformanceOverviewViewModel()
    
    @State private var showAllReviews = false
    @State private var showManageStock = false
    @State private var tenantName: String = "Raburi"
    
    // Wallet
    @State private var scheduledDate: Date = Calendar.current.date(
        byAdding: .month,
        value: 1,
        to: Calendar.current.startOfMonth(for: Date())
    ) ?? Date()
    
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
    
    // Ratings
    @State private var ratingScore: Double = 4.8
    @State private var totalReviews: Int = 27
    
    // Formatter
    private var formattedBalance: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = "."
        return "Rp " + (nf.string(from: totalWalletVM.totalWalletBalance as NSNumber) ?? "0")
    }
    
    private var formattedScheduled: String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        return df.string(from: scheduledDate)
    }
    
    @State private var navPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack(alignment: .top) {
                
                // === Background Header fixed ===
                VStack(spacing: 0) {
                    HeaderBackgroundView(height: 120)  // sama dengan profile view
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    
                    // === Title fixed ===
                    Text("Home")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // === Fixed Header Card (mengikuti profile view) ===
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
                        }
                    }
                    .padding(.horizontal)
                    .offset(y: -10)
                    .zIndex(1)
                    
                    // === Scrollable CONTENT ===
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Scan Button
                            NavigationLink(destination: ScanQRCodeView()) {
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

                            
                            // Wallet
                            walletCard
                            
                            // Performance
                            performanceSection
                            
                            // Weekly Sales
                            Card { LineChart(points: weeklySales) }
                            
                            // Rating
                            ratingSection
                            
                            // Top Menu
                            topMenuSection
                            
                            // Low Stock
                            lowStockSection
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                totalWalletVM.fetchWalletBalance(storeId: "2plb4UCwxjle2Yy6PTdj")
                todayPerformanceVM.fetchTodayStats(storeId: "2plb4UCwxjle2Yy6PTdj")
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: TenantHomeDestination.self) { destination in
                switch destination {

                case .allReviews:
                    AllReviewsTenantView()

                case .manageStock:
                    ManageMenuStockTenantView()
                }
            }

        }
    }
    
    
    // MARK: Wallet Card
    private var walletCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: UIConst.corner)
                .fill(UIConst.brandOrange)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Total Wallet Balance").font(.headline).foregroundColor(.white)
                Text(formattedBalance).font(.title2).fontWeight(.bold).foregroundColor(.white)
                Divider().background(Color.white)
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
    }
    private var performanceSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Performance Overview")
                    .font(.headline)
                
                
                HStack(spacing: 6) {
                    MetricCard(metric: .init(title: "Total Income", value: "Rp \(formatPrice(Double(todayPerformanceVM.totalIncomeToday)))", subtitle: "", icon: "creditcard"))
                    MetricCard(metric: .init(title: "Total Orders", value: "\(todayPerformanceVM.totalOrdersToday) orders", subtitle: "", icon: "cart"))
                    MetricCard(metric: .init(title: "Pending Orders", value: "\(todayPerformanceVM.totalPendingOrdersToday) orders", subtitle: "", icon: "clock"))
                }
            }
        }
    }
    
    private var ratingSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Customer Rating").font(.headline)
                    Spacer()
                    Button("See All") { navPath.append(TenantHomeDestination.allReviews) }
                        .font(.subheadline)
                }
                
                HStack(spacing: 5) {
                    Text(String(format: "%.1f", ratingScore))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(UIConst.brandOrange)
                    Text("/ 5").font(.title3).foregroundColor(.secondary)
                }
                
                Text("(Based on \(totalReviews) reviews)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var topMenuSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Top 3 Menu Items").font(.headline)
                
                HStack {
                    Text("No").frame(width: 30)
                    Text("Menu").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Sold").frame(width: 50, alignment: .trailing)
                }
                .font(.caption)
                .foregroundColor(UIConst.brandOrange)
                
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
    }
    
    private var lowStockSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Low Stock Items").font(.headline)
                    Spacer()
                    Button("See All") { navPath.append(TenantHomeDestination.manageStock) }.font(.subheadline)
                }
                
                HStack {
                    Text("No").frame(width: 30)
                    Text("Menu").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Stock Left").frame(width: 80, alignment: .trailing)
                }
                .font(.caption)
                .foregroundColor(UIConst.brandOrange)
                
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
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
#Preview {
    TenantHomeView()
}

