//
//  ProfileView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

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

    var nextTierLabel: String {
        "Next tier: Silver"
    }

    var body: some View {
        ScrollView {
                VStack(spacing: 16) {
                    header
                    Text("Leaderboard")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 6)
                    
                    PodiumView(users: podiumUsers)

                    rankingTable

                    Text("How far can you go?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    // Badges list
                    VStack(spacing: 10) {
                        ForEach(badges) { badge in
                            BadgeRow(badge: badge)
                        }
                    }
                }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Quest")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.orange, .orange.opacity(0.7)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 130)


            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome, \(userName)!")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Ready to earn more badges this week?")
                            .font(.subheadline).foregroundColor(.white.opacity(0.95))
                    }

                    Spacer()
                    Image(systemName: "shield.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .padding(8)
                        .background(.white.opacity(0.15), in: Circle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // progress
                    ProgressView(value: dailyProgress, total: weeklyTarget)
                        .progressViewStyle(.linear)
                    HStack {
                        Text("\(Int(dailyProgress))/\(Int(weeklyTarget))")
                            .font(.caption).fontWeight(.semibold)
                        Spacer()
                        Text(nextTierLabel)
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }

    private var rankingTable: some View {
        VStack(spacing: 8) {
            // header row
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

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding(.top, 6)
    }
}

struct PodiumView: View {
    let users: [RankUser]

    var body: some View {
        Text("Quest View")
        HStack(alignment: .bottom, spacing: 12) {
            if users.count >= 3 {
                // 2nd
                PodiumCard(user: users[1], place: 2, height: 110, color: .gray)
                // 1st
                PodiumCard(user: users[0], place: 1, height: 140, color: .yellow)
                // 3rd
                PodiumCard(user: users[2], place: 3, height: 95, color: .green)
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
            // avatar-like circle w/ initial
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 54, height: 54)
                Text(String(user.username.dropFirst().prefix(1)).uppercased())
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(color)
            }

            Image(systemName: medal)
                .foregroundColor(place == 1 ? .yellow : .secondary)

            VStack(spacing: 4) {
                Text(user.username.replacingOccurrences(of: "@", with: "")) // show without @ in card
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
            Circle()
                .fill(Color(.systemBackground))
            Circle()
                .stroke(Color.secondary.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round,
                                       lineJoin: .round)
                )
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
            // Circular progress ring (misalnya: 1/3)
            RingProgress(
                current: badge.current,
                target: badge.target,
                color: badge.tint,
                size: 44,
                lineWidth: 6
            )

            // Badge info
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(badge.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Reward points
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                Text("\(badge.rewardPts) pts")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(badge.tint)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    badge.current > 0
                    ? Color.white  // unlocked badge
                    : Color(.secondarySystemBackground) // locked badge
                )
        )
        .shadow(
            color: badge.current > 0
                ? Color.black.opacity(0.08)
                : Color.clear,
            radius: badge.current > 0 ? 4 : 0,
            y: 2
        )
        .animation(.easeInOut(duration: 0.25), value: badge.current)
    }
}
