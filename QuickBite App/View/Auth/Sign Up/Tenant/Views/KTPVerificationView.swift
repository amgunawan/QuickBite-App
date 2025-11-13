//
//  KTPVerificationView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct KTPVerificationView: View {
    @State private var isKtpUploaded = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            RegistrationHeader(step: 3,
                               title: "KTP Verification",
                               subtitle: "Please upload a clear image of your KTP (Kartu Tanda Penduduk) for identity verification")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification Note")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("The name on the KTP must match the Account Holder Name that you are going to provide in the next step.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        if isKtpUploaded {
                            VStack(spacing: 12) {
                                Image("KTP")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(8)
                                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                                    }
                                
                                Text("Uploaded Successfully!")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Button("Click again to replace image") {
                                    isKtpUploaded = false
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                        } else {
                            Button(action: {
                                withAnimation {
                                    isKtpUploaded = true
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "cloud.upload.fill")
                                        .resizable()
                                        .frame(width: 40, height: 30)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Click here to upload KTP photo")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Text("PNG, JPG, or JPEG only (max. 5 MB)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundColor(.secondary)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            
            NavigationLink(destination: PayoutSetupView(),
                           label: {
                OrangeButton(title: "Continue", action: {}, enabled: isKtpUploaded)
            })
            .padding()
        }
    }
}

#Preview {
    NavigationView {
        KTPVerificationView()
    }
}
