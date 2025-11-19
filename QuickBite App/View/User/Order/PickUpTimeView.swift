//
//  PickUpTimeView.swift
//  QuickBite
//
//  Created by student on 19/11/25.
//

import SwiftUI

// Model data untuk Slot Waktu
struct TimeSlot: Identifiable, Equatable {
    let id = UUID()
    let timeRange: String
    let status: String?
    let isRecommended: Bool
    let isWarning: Bool
}

struct PickUpTimeView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTime: TimeSlot?
    
    // Data Waktu
    let timeSlots: [TimeSlot] = [
        TimeSlot(timeRange: "11:45 PM", status: "Still in class", isRecommended: false, isWarning: true),
        TimeSlot(timeRange: "12:00 PM", status: "Recommended", isRecommended: true, isWarning: false),
        TimeSlot(timeRange: "12:15 - 12.30 PM", status: "15 mins after class", isRecommended: false, isWarning: false),
        TimeSlot(timeRange: "12:30 - 12.45 PM", status: nil, isRecommended: false, isWarning: false),
        TimeSlot(timeRange: "1:20 - 2:40 PM", status: "Still in class", isRecommended: false, isWarning: true),
        TimeSlot(timeRange: "2:55 - 3:05 PM", status: "15 mins after class", isRecommended: false, isWarning: false)
    ]
    
    // State lokal untuk seleksi
    @State private var tempSelectedTime: TimeSlot?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
            
            // Grid Waktu
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(timeSlots) { slot in
                        // Cek seleksi berdasarkan timeRange agar sinkron dengan OrderConfirmationView
                        let isSelected = (tempSelectedTime?.timeRange == slot.timeRange)
                        
                        TimeSlotCard(slot: slot, isSelected: isSelected)
                            .opacity(slot.isWarning ? 0.5 : 1.0)
                            .onTapGesture {
                                if !slot.isWarning {
                                    tempSelectedTime = slot
                                }
                            }
                    }
                }
                .padding()
            }
            
            // Tombol Confirm
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
                        .background(Color.orange)
                        .cornerRadius(25)
                }
            }
            .padding()
            .background(Color.white)
        }
        .onAppear {
            // DIPERBARUI: Sinkronisasi saat sheet muncul agar fokus ke pilihan sebelumnya
            if let current = selectedTime {
                // Cari slot yang cocok di list lokal berdasarkan waktu
                if let match = timeSlots.first(where: { $0.timeRange == current.timeRange }) {
                    tempSelectedTime = match
                } else {
                    // Fallback jika data custom
                    tempSelectedTime = current
                }
            } else {
                // Default ke recommended (index 2)
                tempSelectedTime = timeSlots[2]
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .background(Color.white)
    }
}

// Sub-view untuk Kartu Waktu
struct TimeSlotCard: View {
    let slot: TimeSlot
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(slot.timeRange)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            
            if let status = slot.status {
                Text(status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(slot.isWarning ? .red : (slot.isRecommended ? Color.green : .gray))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(
            // Logic Background: Orange pudar jika dipilih, Abu-abu jika tidak
            isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6)
        )
        .cornerRadius(8)
        .overlay(
            // Logic Border: Orange jika dipilih, Clear jika tidak
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.orange : (slot.isRecommended ? Color.green : Color.clear), lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct PickUpTimeView_Previews: PreviewProvider {
    static var previews: some View {
        PickUpTimeView(selectedTime: .constant(nil))
    }
}
