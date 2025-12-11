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

struct TenantHomeView: View {
    let storeId = "2plb4UCwxjle2Yy6PTdj"
    
    @StateObject private var headerVM = TenantHeaderViewModel()
    @StateObject private var totalWalletVM = TotalWalletBalanceViewModel()
    @StateObject private var todayPerformanceVM = TodayPerformanceOverviewViewModel()
    @StateObject private var topMenuVM = TopMenuItemsViewModel()
    @StateObject private var lowStockVM = LowStockItemsViewModel()
    @StateObject private var ratingVM = TenantRatingViewModel()
    
    @State private var showAllReviews = false
    @State private var showManageStock = false
    
    // Wallet
    @State private var scheduledDate: Date = Calendar.current.date(
        byAdding: .month,
        value: 1,
        to: Calendar.current.startOfMonth(for: Date())
    ) ?? Date()
        
    // Ratings
//    @State private var ratingScore: Double = 4.8
//    @State private var totalReviews: Int = 27
    
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
                    HeaderBackgroundView(height: 120)
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
                                Text("Welcome, \(headerVM.tenantName)!")
                                    .font(.title3).fontWeight(.bold)
                                
                                Text("It's a great day to serve delicious bites!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if let url = headerVM.searchImageURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable()
                                            .scaledToFill()
                                            .frame(width: 62, height: 62)
                                            .cornerRadius(8)
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 62, height: 62)
                                    case .failure:
                                        Image(systemName: "exclamationmark.triangle")
                                            .resizable()
                                            .frame(width: 62, height: 62)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 62, height: 62)
                                    .cornerRadius(8)
                            }

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
                totalWalletVM.fetchWalletBalance(storeId: storeId)
                todayPerformanceVM.fetchTodayStats(storeId: storeId)
                topMenuVM.fetchTopMenuItems(storeId: storeId)
                lowStockVM.fetchLowStockItems(storeId: storeId)
                headerVM.loadTenantHeader(storeId: storeId)
                ratingVM.fetchRating(for: storeId)

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
    // MARK: Today's Performance Overview
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
    
    // MARK: Rating
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
                    Text(String(format: "%.1f", ratingVM.averageRating))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(UIConst.brandOrange)
                    Text("/ 5").font(.title3).foregroundColor(.secondary)
                }
                
                Text("(Based on \(ratingVM.totalReviews) reviews)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: Top Menu
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
                
                ForEach(Array(topMenuVM.topMenuItems.enumerated()), id: \.1.id) { index, item in
                    HStack {
                        Text("\(index + 1).").frame(width: 30)
                        Text(item.name).frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(item.sold)").frame(width: 50, alignment: .trailing)
                    }
                    Divider()
                }
            }
        }
    }
    
    // MARK: Low Stock
    private var lowStockSection: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Low Stock Items").font(.headline)
                    Spacer()
                    Button("See All") { navPath.append(TenantHomeDestination.manageStock) }
                        .font(.subheadline)
                }
                
                HStack {
                    Text("No").frame(width: 30)
                    Text("Menu").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Stock Left").frame(width: 80, alignment: .trailing)
                }
                .font(.caption)
                .foregroundColor(UIConst.brandOrange)
                
                Divider()
                
                ForEach(Array(lowStockVM.lowStockItems.enumerated()), id: \.1.id) { index, item in
                    HStack {
                        Text("\(index + 1).").frame(width: 30)
                        Text(item.name).frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(item.stockLeft)").frame(width: 80, alignment: .trailing)
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

