//
//  OrderDeadlineSheet.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI

struct OrderDeadlineSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var onSave: (Date) -> Void
    
    // State dummy untuk keperluan tampilan (bisa diganti Binding nanti)
    @State private var selectedDate = Date()
    @State private var showTimePicker = false
    
    // Formatter untuk menampilkan waktu
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    init(initialDate: Date? = nil, onSave: @escaping (Date) -> Void) {
            self.onSave = onSave
            // Initialize selectedDate with initialDate or current date
            _selectedDate = State(initialValue: initialDate ?? Date())
        }
    var body: some View {
        VStack(spacing: 24) {
            
            // Title & Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Set a deadline for members to add items")
                    .font(.title3.bold()) // Bold title
                    .foregroundColor(.black)
                    .padding(.top, 30)
                
                Text("We'll give you a little reminder to place the order when the deadline's getting close. Feel free to adjust it if your members need a bit more time.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true) // Wrap text
                    .lineSpacing(2)
            }
            .padding(.horizontal)
            
            // Inputs (Date & Time)
            VStack(spacing: 16) {
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
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                )
                
                // Time Input (Button to toggle picker)
                VStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            showTimePicker.toggle()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "clock") // Icon jam orange sesuai gambar
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            // Menampilkan waktu yang dipilih atau teks default jika perlu
                            Text(timeFormatter.string(from: selectedDate))
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(showTimePicker ? Color.orange : Color(.systemGray4), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Hour Picker (Wheel Style)
                
                    if showTimePicker {
                        Divider()
                            .padding(.top,10)
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                // Set Deadline Button
                Button(action: {
                    // Call the onSave closure with the selected date
                    onSave(selectedDate)
                    dismiss()
                }) {
                    Text("Set deadline")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(30)
                }
                
                // Continue without deadline Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue without deadline")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1)) // Light orange background
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .presentationDetents([showTimePicker ? .large : .height(480)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible) // Kita buat handle manual
    }
}

struct OrderDeadlineSheet_Previews: PreviewProvider {
    static var previews: some View {
        OrderDeadlineSheet(onSave: { date in
            print("Deadline saved: \(date)")
        })
    }
}
