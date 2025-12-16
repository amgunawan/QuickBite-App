//
//  AppNavigationState.swift
//  QuickBite App
//
//  Created by jessica tedja on 16/12/25.
//

import Foundation
import SwiftUI
import Combine

enum ActivitySegment {
    case history
    case inProgress
}

final class AppNavigationState: ObservableObject {

    // ================= TAB BAR =================
    // 0 = Home, 1 = Activity, 2 = Quest, 3 = Profile
    @Published var selectedTab: Int = 0

    // ================= ACTIVITY =================
    @Published var activitySegment: ActivitySegment = .history
    @Published var activeOrderId: String? = nil

    // ================= CART FLOW =================
    // 🔥 SATU-SATUNYA FLAG UNTUK BUKA / TUTUP CART
    @Published var isCartPresented: Bool = false

    // ================= OTHER FLOW =================
    @Published var showTenantTab: Bool = false
}
