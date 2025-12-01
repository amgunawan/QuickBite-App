//
//  OrderDeadlineSheet.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI

struct OrderDeadlineSheet: View {
    @Environment(\.dismiss) var dismiss
    
    // Action closure to pass the selected date back to the parent
    var onSave: (Date) -> Void
    
    // State for local selection
    @State private var selectedDate: Date
    // REMOVED: showTimePicker state is no longer needed
    // @State private var showTimePicker = false
    
    // Init to accept initial date
    init(initialDate: Date? = nil, onSave: @escaping (Date) -> Void) {
        self.onSave = onSave
        // Initialize selectedDate with initialDate or current date
        let start = initialDate ?? Date()
        _selectedDate = State(initialValue: start)
    }
    
    // REMOVED: timeFormatter is no longer needed for the button label
    
    // Helper to calculate closing time for today (e.g., 10:00 PM)
    private var closingTimeToday: Date {
        let calendar = Calendar.current
        let now = Date()
        // Set closing time to 10:00 PM (22:00) today
        // You can change '22' to whatever hour the restaurant closes
        if let closeDate = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: now) {
            // Safety check: If 'now' is somehow already past 10 PM,
            // return 'now' + 1 minute so the range isn't invalid (min > max).
            return closeDate > now ? closeDate : now.addingTimeInterval(60)
        }
        return now.addingTimeInterval(60) // Fallback
    }
    
    // Define Valid Range
    private var validDateRange: ClosedRange<Date> {
        let now = Date()
        let end = closingTimeToday
        
        // Check if we are already past closing time
        if now > end {
            return now...now.addingTimeInterval(60)
        } else {
            // Normal operation: Now until Closing Time
            return now...end
        }
    }
    
    // Check if Restaurant is Closed
    private var isRestaurantClosed: Bool {
        return Date() > closingTimeToday
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Title & Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Set a deadline for members to add items")
                    .font(.title3.bold())
                    .foregroundColor(.black)
                    
                
                Text("We'll give you a little reminder to place the order when the deadline's getting close. Feel free to adjust it if your members need a bit more time.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true) // Wrap text
                    .lineSpacing(2)
            }
            .padding(.horizontal)
            .padding(.top, 30)
            
            // Inputs (Date & Time)
            VStack(spacing: 16) {
                // Date Input (Static "Today")
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                    Text("Today")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                )
                
                // Time Picker (Always Visible)
                if isRestaurantClosed {
                    // Show message if closed
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        Text("Restaurant Closed")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray5), lineWidth: 1.5)
                    )
                } else {
                    // Show DatePicker directly
                    DatePicker("", selection: $selectedDate, in: validDateRange, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxHeight: 150) // Limit height to keep it compact
                        .clipped()
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                // Set Deadline Button
                Button(action: {
                    onSave(selectedDate)
                    dismiss()
                }) {
                    Text("Set deadline")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isRestaurantClosed ? Color.gray : Color.orange)
                        .cornerRadius(30)
                }
                .disabled(isRestaurantClosed)
                
                // Continue without deadline Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue without deadline")
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.white)
        // Fixed height detent since picker is always visible
        .presentationDetents([.height(530)])
        .presentationCornerRadius(50)
        .presentationDragIndicator(.visible)
    }
}

struct OrderDeadlineSheet_Previews: PreviewProvider {
    static var previews: some View {
        OrderDeadlineSheet(onSave: { _ in })
    }
}
