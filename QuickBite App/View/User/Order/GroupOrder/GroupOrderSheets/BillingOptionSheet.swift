//
//  BillingOptionSheet.swift
//  QuickBite
//
//  Created by student on 26/11/25.
//

import SwiftUI

// Model Opsi Pembayaran
enum BillingOption: String, CaseIterable, Identifiable {
    case individual = "Everyone pays for themselves"
    case splitEvenly = "Everyone pays an equal share"
    case full = "You pay for everyone"
    
    var id: String { self.rawValue }
    
    var description: String? {
        switch self {
        case .individual:
            return "Each member pays for their items based on the stated menu price. Fees are split equally."
        case .splitEvenly:
            return "Order total is divided equally."
        case .full:
            return nil
        }
    }
}

struct BillingOptionSheet: View {
    @Binding var selectedOption: BillingOption
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Judul
            Text("Choose who pays")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            // List Opsi
            VStack(spacing: 0) {
                ForEach(BillingOption.allCases) { option in
                    BillingOptionRow(
                        option: option,
                        isSelected: selectedOption == option,
                        action: {
                            selectedOption = option
                            // Opsional: Tutup sheet langsung setelah memilih, atau biarkan user swipe down
                            // dismiss()
                        }
                    )
                    
                    // Spacer antar item (opsional, tapi di screenshot terlihat ada jarak)
                    if option != BillingOption.allCases.last {
                        Spacer().frame(height: 20)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .presentationDetents([.height(300)]) // Tinggi sheet disesuaikan
        .presentationDragIndicator(.visible)
        .background(Color.white)
    }
}

// Komponen Baris Opsi
struct BillingOptionRow: View {
    let option: BillingOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    if let desc = option.description {
                        Text(desc)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true) // Agar text wrap ke bawah
                    }
                }
                
                Spacer()
                
                // Radio Button Icon
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .contentShape(Rectangle()) // Agar seluruh area bisa diklik
        }
        .buttonStyle(.plain)
    }
}

struct BillingOptionSheet_Previews: PreviewProvider {
    static var previews: some View {
        BillingOptionSheet(selectedOption: .constant(.individual))
    }
}
