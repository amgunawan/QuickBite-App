//
//  QuestView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

// MARK: - Models

struct RankUser: Identifiable {
    let id = UUID()
    let username: String
    let points: Int
    let tier: String
    var initial: String { String(username.dropFirst()).prefix(1).uppercased() }
}

struct BadgeItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let current: Int
    let target: Int
    let rewardPts: Int
    let tint: Color
}

struct QuestView: View {
    let userName = "Angela"
    @State private var dailyProgress: Double = 30
    private let weeklyTarget: Double = 100
    @State private var showLockedAlert = false

    private let podiumUsers: [RankUser] = [
        .init(username: "@hsutedjo", points: 700, tier: "Diamond"),
        .init(username: "@natgwk", points: 630, tier: "Silver"),
        .init(username: "@jessilau", points: 550, tier: "Gold")
    ]

    private let topUsers: [RankUser] = [
        .init(username: "@hsutedjo", points: 700, tier: "Diamond"),
        .init(username: "@natgwk", points: 630, tier: "Silver"),
        .init(username: "@jessilau", points: 550, tier: "Gold"),
        .init(username: "@annetan01", points: 450, tier: "—"),
        .init(username: "@sharonwd", points: 300, tier: "—")
    ]

    private let badges: [BadgeItem] = [
        .init(title: "Beginner Badges",
              subtitle: "Spend min. Rp50K to earn 30 pts.",
              current: 1, target: 3, rewardPts: 30, tint: .orange),
        .init(title: "Explorer Badges",
              subtitle: "Spend Rp150K total at 3 tenants for 200 pts.",
              current: 0, target: 5, rewardPts: 200, tint: .blue),
        .init(title: "Challenge Badges",
              subtitle: "Grab 5 Last Call items in 3 days for 300 pts.",
              current: 0, target: 5, rewardPts: 300, tint: .pink),
        .init(title: "Loyalty Badges",
              subtitle: "Keep a 7-day streak to earn 650 pts.",
              current: 0, target: 7, rewardPts: 650, tint: .green),
        .init(title: "Legendary Badges",
              subtitle: "Reach Rp500K total to unlock all for 1000 pts.",
              current: 0, target: 2, rewardPts: 1000, tint: .purple)
    ]

    var nextTierLabel: String { "Next tier: Silver" }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    HeaderBackgroundView(height: 100)
                    Spacer()
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: - Title
                        Text("Quest")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // MARK: - Header Card (user progress)
                        headerCard
                            .padding(.horizontal)
                            .offset(y: -10)
                            .zIndex(1)

                        // MARK: - Leaderboard Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Leaderboard")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.top, 6)

                            PodiumView(users: podiumUsers)

                            rankingTable

                            Text("How far can you go?")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.top, 8)

                            // MARK: - Badges
                            VStack(spacing: 16) {
                                ForEach(badges) { badge in
                                    BadgeRow(badge: badge)
                                        .onTapGesture {
                                            if badge.current == 0 {
                                                showLockedAlert = true
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        .offset(y: -6)
                    }
                }
            }
            .alert("Badge Locked", isPresented: $showLockedAlert) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text("You’re almost there! Finish all required challenges before this badge can be unlocked.")
            }
            .tint(.orange)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Header Card (styled like ProfileCard)
    private var headerCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.18))
                Image(systemName: "shield.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome, \(userName)!")
                    .font(.headline)
                Text("Ready to earn more badges this week?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(spacing: 6) {
                    BarProgress(value: dailyProgress, total: weeklyTarget)
                    HStack {
                        Text("\(Int(dailyProgress))/\(Int(weeklyTarget))")
                            .font(.caption).bold()
                        Spacer()
                        Text(nextTierLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
                .shadow(color: .black.opacity(0.03), radius: 2,  x: 0, y: 1)
        )
    }

    // MARK: Progress Bar
    private struct BarProgress: View {
        var value: Double
        var total: Double

        private var pct: CGFloat {
            guard total > 0 else { return 0 }
            return min(max(CGFloat(value/total), 0), 1)
        }

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    Capsule()
                        .fill(Color.orange)
                        .frame(width: geo.size.width * pct, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: Ranking Table
    private var rankingTable: some View {
        VStack(spacing: 8) {
            RankRow(rank: "Rank", username: "Username", points: "Points", isHeader: true)
            ForEach(Array(topUsers.enumerated()), id: \.offset) { index, u in
                RankRow(rank: "\(index + 1)", username: u.username, points: "\(u.points)")
            }
        }
        .padding(10)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

// MARK: - Podium

struct PodiumView: View {
    let users: [RankUser]

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if users.count >= 3 {
                PodiumCard(user: users[1], place: 2, height: 110, color: .gray)
                PodiumCard(user: users[0], place: 1, height: 140, color: .yellow)
                PodiumCard(user: users[2], place: 3, height: 95,  color: .green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

struct PodiumCard: View {
    let user: RankUser
    let place: Int
    let height: CGFloat
    let color: Color

    var medal: String {
        switch place {
        case 1: return "crown.fill"
        case 2: return "2.circle.fill"
        default: return "3.circle.fill"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 54, height: 54)
                Text(String(user.username.dropFirst().prefix(1)).uppercased())
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(color)
            }

            Image(systemName: medal)
                .foregroundColor(place == 1 ? .yellow : .secondary)

            VStack(spacing: 4) {
                Text(user.username.replacingOccurrences(of: "@", with: ""))
                    .font(.footnote).fontWeight(.semibold)
                Text("\(user.points)")
                    .font(.headline)
                Text(user.tier)
                    .font(.caption2).foregroundColor(.secondary)
            }
            .padding(.top, 2)

            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.15))
                .frame(width: 86, height: height)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Components

struct RingProgress: View {
    let current: Int
    let target: Int
    let color: Color
    var size: CGFloat = 44
    var lineWidth: CGFloat = 8

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1)
    }

    var body: some View {
        ZStack {
            Circle().fill(Color(.systemBackground))
            Circle().stroke(Color.secondary.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))
            Text("\(current)/\(target)")
                .font(.footnote).fontWeight(.semibold)
        }
        .frame(width: size, height: size)
    }
}

struct RankRow: View {
    let rank: String
    let username: String
    let points: String
    var isHeader: Bool = false

    var body: some View {
        HStack {
            Text(rank)
                .frame(width: 36, alignment: .leading)
                .font(isHeader ? .caption.bold() : .subheadline)

            Text(username)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(isHeader ? .caption.bold() : .subheadline)

            Text(points)
                .frame(width: 70, alignment: .trailing)
                .font(isHeader ? .caption.bold() : .subheadline)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isHeader ? Color.orange.opacity(0.4) : Color.orange.opacity(0.35), lineWidth: isHeader ? 1.2 : 0.8)
                .background(isHeader ? Color.orange.opacity(0.08) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
    }
}

struct BadgeRow: View {
    let badge: BadgeItem

    var body: some View {
        HStack(spacing: 12) {
            RingProgress(current: badge.current, target: badge.target, color: badge.tint, size: 44, lineWidth: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(badge.title)
                    .font(.subheadline).fontWeight(.semibold)
                Text(badge.subtitle)
                    .font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                Text("\(badge.rewardPts) pts")
                    .font(.caption).fontWeight(.semibold)
            }
            .foregroundColor(badge.tint)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(badge.current > 0 ? Color.white : Color(.secondarySystemBackground))
        )
        .shadow(color: badge.current > 0 ? Color.black.opacity(0.08) : Color.clear,
                radius: badge.current > 0 ? 4 : 0, y: 2)
        .animation(.easeInOut(duration: 0.25), value: badge.current)
    }
}

#Preview {
    QuestView()
}
