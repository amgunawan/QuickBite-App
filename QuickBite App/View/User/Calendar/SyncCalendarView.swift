//
//  SyncCalendarView.swift
//  QuickBite
//
//  Created by student on 12/12/25.
//

import SwiftUI

// --- 1. COLORS ---
struct AppColors {
    static let primaryOrange = Color.orange
    static let textBlack     = Color.primary
}

struct SyncCalendarView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // --- CONTENT SWITCHER ---
            if calendarManager.isSynced {
                SuccessView()
            } else {
                IntroSyncView()
            }
        }
        // 1. Use Native Navigation Title
        .navigationTitle("Sync My Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subview: Intro/Sync State
    func IntroSyncView() -> some View {
        // 2. Changed ScrollView to VStack
        VStack(spacing: 0) {
            
            Spacer() // Push content to center
            
            // --- ICON & TITLE ---
            VStack(spacing: 20) {
                // Big Gradient Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100) // Slightly smaller to fit fixed screen
                    
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45)
                        .foregroundColor(.white)
                }
                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 10)
                
                // Title & Subtitle
                VStack(spacing: 8) {
                    Text("Order with Ease,\nPick Up Right on Time")
                        .font(.title3) // Adjusted size
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.textBlack)
                    
                    Text("Let QuickBite handle your schedule. Turn on the Smart Feature to sync with your classes.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
            }
            
            Spacer() // Space between header and list
            
            // --- FEATURES LIST ---
            VStack(alignment: .leading, spacing: 24) {
                
                FeatureRow(
                    icon: "clock.fill",
                    title: "Smart Timing Suggestions",
                    subtitle: "Auto-suggest perfect pickup times."
                )
                
                FeatureRow(
                    icon: "lock.fill",
                    title: "Secure & Private",
                    subtitle: "We only access 'free/busy' status."
                )
            }
            .padding(.horizontal, 24)
            
            Spacer() // Push button to bottom
            
            // --- SYNC BUTTON ---
            Button(action: {
                calendarManager.syncCalendar()
            }) {
                Text("Sync Calendar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(AppColors.primaryOrange)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Subview: Success State
    func SuccessView() -> some View {
        VStack {
            Spacer()
            
            // 1. Success Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.green)
                    .font(.system(size: 50, weight: .bold))
            }
            .padding(.bottom, 24)
            
            // 2. Title
            Text("You’re All Set!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 8)
            
            // 3. Description
            Text("QuickBite is now connected to your calendar. We'll start sending you smart notifications and recommendations.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
            
            // 4. Done Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(AppColors.primaryOrange)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}


// --- PREVIEW ---
struct SyncCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SyncCalendarView()
                .environmentObject(CalendarManager())
        }
    }
}
