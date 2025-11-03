//
//  FindAccountView.swift
//  QuickBite
//
//  Created by Angela on 03/11/25.
//

import SwiftUI

struct ConfirmAccountView: View {
    @State private var code: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var timeRemaining = 60
    @State private var timerActive = true
    
    var body: some View {
        NavigationStack {
            VStack(alignment:. leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm your account")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We sent a code to your email. Enter that code to confirm your account.")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $code[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: .infinity, height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .focused($focusedIndex, equals: index)
                            .onChange(of: code[index]) { oldValue, newValue in
                                if newValue.count > 1 {
                                    code[index] = String(newValue.prefix(1))
                                }
                                if newValue.count == 1 {
                                    if index < 5 {
                                        focusedIndex = index + 1
                                    } else {
                                        focusedIndex = nil
                                    }
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Resend code timer
                if timerActive {
                    Text("Resend code in \(timeRemaining)s")
                        .foregroundColor(.gray)
                        .onAppear(perform: startTimer)
                } else {
                    Button("Resend code") {
                        resendCode()
                    }
                    .foregroundColor(.orange)
                }
                
                NavigationLink(destination: CreateNewPasswordView()) {
                    Text("Continue")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(24)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // Timer logic
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                timerActive = false
            }
        }
    }
    
    func resendCode() {
        timeRemaining = 60
        timerActive = true
        startTimer()
    }
    
}

#Preview {
    ConfirmAccountView()
}
