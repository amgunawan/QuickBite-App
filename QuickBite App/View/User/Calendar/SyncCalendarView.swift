//
//  SyncCalendarView.swift
//  QuickBite
//
//  Created by student on 12/12/25.
//

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
    
    // State to handle the transition if needed, though simpler is better
    // The view will automatically update when calendarManager.isSynced changes
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- NAV BAR ---
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
                Text("Sync My Calendar")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Color.clear.frame(width: 44, height: 44) // Spacer for balance
            }
            .padding()
            
            // --- CONTENT SWITCHER ---
            if calendarManager.isSynced {
                // SHOW SUCCESS SCREEN (Matches your screenshot)
                SuccessView()
            } else {
                // SHOW INTRO / SYNC SCREEN (Your original code)
                IntroSyncView()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Subview: Intro/Sync State
    func IntroSyncView() -> some View {
        VStack {
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    Spacer().frame(height: 20)
                    
                    // 1. Big Gradient Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 10)
                    
                    // 2. Title & Subtitle
                    VStack(spacing: 12) {
                        Text("Order with Ease,\nPick Up Right on Time")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppColors.textBlack)
                        
                        Text("Let QuickBite handle your schedule. Turn on the Smart Feature to sync with your classes.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .lineSpacing(4)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    // 3. Features List
                    VStack(alignment: .leading, spacing: 30) {
                        FeatureRow(
                            icon: "bell.fill",
                            title: "Proactive Notifications",
                            subtitle: "We'll remind you to order before your class ends."
                        )
                        
                        FeatureRow(
                            icon: "clock.fill",
                            title: "Smart Timing Suggestions",
                            subtitle: "We'll automatically suggest the perfect pickup time on the checkout page."
                        )
                        
                        FeatureRow(
                            icon: "lock.fill",
                            title: "Secure & Private",
                            subtitle: "We only access your 'free/busy' times and never save any event details."
                        )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
            
            // SYNC BUTTON
            VStack {
                Button(action: {
                    // Simulate Sync Action
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
    }
    
    // MARK: - Subview: Success State
    func SuccessView() -> some View {
        VStack {
            Spacer()
            
            // 1. Success Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2)) // Light green background
                    .frame(width: 140, height: 140)
                
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.green) // Darker green check
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
                // Dismiss the view
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
        SyncCalendarView()
    }
}
