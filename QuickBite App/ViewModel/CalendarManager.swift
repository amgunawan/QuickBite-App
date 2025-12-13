//
//  CalendarManager.swift
//  QuickBite
//
//  Created by student on 12/12/25.
//

import SwiftUI
import Combine
import GoogleSignIn

// Note: We use the CalendarEvent struct defined in CalendarEvent.swift.
// Make sure CalendarEvent conforms to Identifiable.

enum SlotStatus {
    case busy
    case available
    case justFree
    case recommended
}

class CalendarManager: ObservableObject {
    @Published var isSynced = false
    @Published var events: [CalendarEvent] = [] // Uses your file's struct
    
    // The specific permission we need
    private let calendarScope = "https://www.googleapis.com/auth/calendar.events.readonly"
    
    // --- INITIALIZER (Auto-Restore Logic) ---
    init() {
        restoreState()
    }
    
    // --- RESTORE PREVIOUS SESSION ---
    func restoreState() {
        // Check if GIDSignIn has a saved user in the keychain
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let user = user {
                    // Check if this user has already granted the Calendar permission
                    if let scopes = user.grantedScopes, scopes.contains(self.calendarScope) {
                        DispatchQueue.main.async {
                            self.isSynced = true
                            print("✅ Restored Calendar Sync for user: \(user.profile?.email ?? "Unknown")")
                            // Immediately fetch events so the app is ready
                            self.fetchTodayEvents()
                        }
                    } else {
                        print("⚠️ User restored, but Calendar scope is missing.")
                    }
                } else if let error = error {
                    print("❌ Failed to restore sign-in: \(error.localizedDescription)")
                }
            }
        } else {
            print("ℹ️ No previous Google Sign-In found.")
        }
    }
    
    // 1. Sign In & Request Access (Manual Trigger)
    func syncCalendar() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Error: Could not find root view controller")
            return
        }
        
        // STEP 1: Basic Sign In
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            guard let result = signInResult else { return }
            
            // STEP 2: Ask for Calendar Access
            result.user.addScopes([self.calendarScope], presenting: rootViewController) { result, error in
                
                // Handle "Already Granted" Error (-8)
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == -8 {
                        print("✅ Scopes already granted! Proceeding...")
                    } else {
                        print("❌ Error adding calendar scope: \(error.localizedDescription)")
                        return
                    }
                }
                
                DispatchQueue.main.async {
                    self.isSynced = true
                    self.fetchTodayEvents()
                }
            }
        }
    }
    
    // 2. Fetch Events
    func fetchTodayEvents() {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else { return }
        
        currentUser.refreshTokensIfNeeded { user, error in
            guard let accessToken = user?.accessToken.tokenString else { return }
            print("🔄 Fetching events with valid token...")
            self.getEventsFromAPI(accessToken: accessToken)
        }
    }
    
    // 3. Call Google Calendar API
    private func getEventsFromAPI(accessToken: String) {
        let now = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let formatter = ISO8601DateFormatter()
        let timeMin = formatter.string(from: startOfDay)
        let timeMax = formatter.string(from: endOfDay)
        
        let urlString = "https://www.googleapis.com/calendar/v3/calendars/primary/events?timeMin=\(timeMin)&timeMax=\(timeMax)&singleEvents=true&orderBy=startTime"
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let items = json["items"] as? [[String: Any]] {
                
                var newEvents: [CalendarEvent] = []
                
                for item in items {
                    if let startDict = item["start"] as? [String: Any],
                       let endDict = item["end"] as? [String: Any],
                       let startStr = startDict["dateTime"] as? String,
                       let endStr = endDict["dateTime"] as? String {
                        
                        let infoFormatter = ISO8601DateFormatter()
                        if let startDate = infoFormatter.date(from: startStr),
                           let endDate = infoFormatter.date(from: endStr) {
                            
                            let summary = item["summary"] as? String ?? "Busy"
                            
                            // Uses init from your CalendarEvent.swift
                             newEvents.append(CalendarEvent(title: summary, startTime: startDate, endTime: endDate))
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.events = newEvents
                    print("✅ Successfully loaded \(newEvents.count) events.")
                }
            }
        }.resume()
    }
    
    // 4. Check Availability Logic
    func checkAvailability(for slotTime: Date) -> (status: SlotStatus, message: String) {
        // Assume a slot is 15 mins long
        let slotEnd = slotTime.addingTimeInterval(15 * 60)
        
        for event in events {
            // Check for Overlap: (StartA < EndB) and (EndA > StartB)
            if event.startTime < slotEnd && event.endTime > slotTime {
                return (.busy, "Still in class")
            }
            
            // Check if slot starts shortly after an event ends (within 20 mins)
            let timeDifference = slotTime.timeIntervalSince(event.endTime)
            if timeDifference >= 0 && timeDifference <= (20 * 60) {
                 return (.justFree, "15 mins after class")
            }
        }
        
        return (.available, "")
    }
}
