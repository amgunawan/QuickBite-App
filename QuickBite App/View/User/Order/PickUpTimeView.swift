//
//  PickUpTimeView.swift
//  QuickBite
//
//  Created by student on 19/11/25.
//

import SwiftUI

// Model data for Time Slot
struct TimeSlot: Identifiable, Equatable {
    let id = UUID()
    let timeRange: String
    let status: String?
    let isRecommended: Bool
    let isWarning: Bool
    let rawDate: Date?
}

struct PickUpTimeView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTime: TimeSlot?
    
    // Global Calendar Manager
    @EnvironmentObject var calendarManager: CalendarManager
    
    // NEW: Receive Store Closing Time (Format: "HH:mm", e.g., "22:00")
    var storeClosingTime: String
    
    // Local state for selection
    @State private var tempSelectedTime: TimeSlot?
    
    // Dynamic Slots
    var timeSlots: [TimeSlot] {
        return generateTimeSlots()
    }

    var body: some View {
        VStack(spacing: 0) {
            // --- Header ---
            HStack {
                Spacer()
                Text("Select Pick Up Time")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            // --- Time Grid ---
            ScrollView {
                // Status Indicator
                if calendarManager.isSynced {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Synced with Calendar")
                            .foregroundColor(.green)
                    }
                    .font(.caption)
                    .padding(.top, 8)
                } else {
                    Text("Sync Calendar to see class conflicts")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                
                // GRID
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(timeSlots) { slot in
                        let isSelected = (tempSelectedTime?.timeRange == slot.timeRange)
                        
                        TimeSlotCard(slot: slot, isSelected: isSelected)
                            .opacity(slot.isWarning ? 0.6 : 1.0) // Dim busy slots
                            .onTapGesture {
                                // Disable selection if it's a warning (Busy)
                                if !slot.isWarning {
                                    tempSelectedTime = slot
                                }
                            }
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
            
            // --- Confirm Button ---
            VStack {
                Button(action: {
                    selectedTime = tempSelectedTime
                    dismiss()
                }) {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(tempSelectedTime == nil ? Color.gray : Color.orange)
                        .cornerRadius(25)
                }
                .disabled(tempSelectedTime == nil)
            }
            .padding()
            .background(Color.white)
        }
        .onAppear {
            // Set initial selection logic
            if let current = selectedTime {
                if let match = timeSlots.first(where: { $0.timeRange == current.timeRange }) {
                    tempSelectedTime = match
                } else {
                    tempSelectedTime = current
                }
            }
            
            // Refresh events
            if calendarManager.isSynced {
                calendarManager.fetchTodayEvents()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .background(Color.white)
    }
    
    // --- CORE LOGIC: GROUPING & DYNAMIC END TIME ---
    func generateTimeSlots() -> [TimeSlot] {
        var slots: [TimeSlot] = []
        let cal = Calendar.current
        let now = Date()
        
        // 1. Calculate CUTOFF Time (Store Close - 15 mins)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let closeDatePart = dateFormatter.date(from: storeClosingTime) else { return [] }
        
        // Combine "Today" with "CloseTime"
        var closeDate = cal.date(bySettingHour: cal.component(.hour, from: closeDatePart),
                                 minute: cal.component(.minute, from: closeDatePart),
                                 second: 0, of: now)!
        
        // If close time is smaller than current hour (e.g. 1 AM), treat as tomorrow
        if closeDate < now.addingTimeInterval(-12*3600) {
             closeDate = cal.date(byAdding: .day, value: 1, to: closeDate)!
        }

        // The last possible pickup is 15 mins before close
        let lastPickupTime = cal.date(byAdding: .minute, value: -15, to: closeDate)!
        
        // 2. Calculate START Time (Round up to next 15 mins)
        let minuteInterval = 15
        let components = cal.dateComponents([.minute], from: now)
        guard let minute = components.minute else { return [] }
        let remainder = minute % minuteInterval
        let addMinutes = minuteInterval - remainder
        guard let nextSlot = cal.date(byAdding: .minute, value: addMinutes, to: now) else { return [] }
        
        var current = nextSlot
        
        // 3. GENERATION LOOP
        // Continue as long as current slot start is before the last pickup time
        while current <= lastPickupTime {
            
            // Check status of CURRENT 15 min block
            let initialCheck = calendarManager.checkAvailability(for: current)
            
            var slotEndTime = cal.date(byAdding: .minute, value: 15, to: current)!
            var slotStatus = initialCheck.status
            var displayStatusText: String? = nil
            var isWarn = false
            var isRec = false
            
            // --- GROUPING LOGIC ---
            if initialCheck.status == .busy {
                // It is busy! Let's look ahead to see how long it stays busy.
                isWarn = true
                displayStatusText = "Occupied ⛔️" // Grouped message
                
                // Keep extending `slotEndTime` by 15 mins as long as the next block is ALSO busy
                while slotEndTime < lastPickupTime {
                    let nextBlockCheck = calendarManager.checkAvailability(for: slotEndTime)
                    if nextBlockCheck.status == .busy {
                        // Extend the block
                        slotEndTime = cal.date(byAdding: .minute, value: 15, to: slotEndTime)!
                    } else {
                        // Stop extending, the next block is free
                        break
                    }
                }
            } else {
                // --- NORMAL LOGIC (Not Busy) ---
                switch initialCheck.status {
                case .justFree:
                    displayStatusText = "Perfect Timing! ⏰"
                    isRec = false
                case .recommended:
                    displayStatusText = "Recommended"
                    isRec = true
                case .available:
                    displayStatusText = nil
                default: break
                }
            }
            
            // 4. Format the String (e.g., "4:00 - 5:30 PM")
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm"
            let startStr = timeFormatter.string(from: current)
            let endStr = timeFormatter.string(from: slotEndTime)
            
            let amPm = DateFormatter()
            amPm.dateFormat = "a"
            let period = amPm.string(from: slotEndTime)
            
            let rangeString = "\(startStr) - \(endStr) \(period)"
            
            // 5. Create Slot
            let slot = TimeSlot(
                timeRange: rangeString,
                status: displayStatusText,
                isRecommended: isRec,
                isWarning: isWarn,
                rawDate: current
            )
            slots.append(slot)
            
            // 6. Jump `current` to the end of this slot (skips the grouped busy times)
            current = slotEndTime
        }
        
        return slots
    }
}

// Sub-view for Card
struct TimeSlotCard: View {
    let slot: TimeSlot
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(slot.timeRange)
                .font(.system(size: 13, weight: .bold)) // Slightly smaller for long merged times
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            if let status = slot.status {
                Text(status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(slot.isWarning ? .red : (slot.isRecommended ? Color.green : .gray))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(
            isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6)
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.orange : (slot.isRecommended ? Color.green : Color.clear), lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct PickUpTimeView_Previews: PreviewProvider {
    static var previews: some View {
        // Pass a dummy time like "22:00" for preview
        PickUpTimeView(selectedTime: .constant(nil), storeClosingTime: "22:00")
            .environmentObject(CalendarManager())
    }
}
