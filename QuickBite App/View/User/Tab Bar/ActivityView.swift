//
//  ActivityView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct ActivityView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Picker("", selection: $selectedTab) {
                Text("History").tag(0)
                Text("In Progress").tag(1)
            }
            .pickerStyle(.segmented)
            
            VStack(spacing: 16) {
                HStack {
                    Text("24 Okt, 13:00")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Order Finished")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 12) {
                    Image("Raburi")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Raburi")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("1 Chicken Katsu Shirokara....")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Text("Rp32.500")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // TODO: Handle action
                    }) {
                        Text("Buy Again")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5))
            )
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    ActivityView()
}
