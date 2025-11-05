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
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Text("Activity")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("", selection: $selectedTab) {
                    Text("History").tag(0)
                    Text("In Progress").tag(1)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        ForEach(0..<3, id: \.self) { index in
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
                                        
                                        Text("1 Chicken Katsu Shirokara Ramen")
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
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.orange)
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                if index == 0 {
                                    Divider()
                                    
                                    HStack(spacing: 12) {
                                        Text("Give us rating!")
                                            .font(.subheadline)
                                        Spacer()
                                        HStack(spacing: 4) {
                                            ForEach(1..<6, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .foregroundStyle(Color(.systemGray4))
                                            }
                                        }
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
                        }
                    } else {
                        ForEach(0..<2, id: \.self) { index in
                            VStack(spacing: 16) {
                                HStack {
                                    Text("25 Okt, 16:00")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    if index == 0 {
                                        HStack(spacing: 4) {
                                            Text("Ready in:")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Text("10 minutes")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.orange)
                                        }
                                    } else {
                                        Text("Pick Up Available")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    Image("KayaBoys")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Kaya Boys")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text("1 Kaya Sandwiches")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                        
                                        Text("Rp15.000")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // TODO: Handle action
                                    }) {
                                        Text("Track Order")
                                            .font(.footnote)
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
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    ActivityView()
}
