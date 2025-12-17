//
//  StoreBrandingComponents.swift
//  QuickBite
//
//  Created by student on 20/11/25.
//

import SwiftUI

// MARK: - Weekday Enum
enum Weekday: String, CaseIterable, Identifiable, Hashable {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday

    var id: String { rawValue }
}

// MARK: - GroupBoxRow
struct GroupBoxRow<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.12)
            HStack { content() }
                .padding(.horizontal, 16)
                .frame(height: 48)
        }
    }
}

// MARK: - TimePickerSheettttt
struct TimePickerSheet: View {
    let title: String
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.top, 8)
                
                Button("Done") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - WeeklyScheduleView
struct WeeklyScheduleView: View {
    @Binding var openDays: Set<Weekday>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(Weekday.allCases) { day in
                Toggle(day.rawValue.capitalized,
                       isOn: Binding(
                            get: { openDays.contains(day) },
                            set: { newValue in
                                if newValue { openDays.insert(day) }
                                else { openDays.remove(day) }
                            }
                       )
                )
            }
        }
        .navigationTitle("Weekly Schedule")
        .toolbar {
            Button("Done") { dismiss() }
        }
    }
}
