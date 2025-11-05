//
//  OTP.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI
import Combine

class OTPViewModel: ObservableObject {
    @Published var code = ""
    @Published var timeRemaining = 60
    @Published var timerActive = true
    
    private var timer: Timer?
    
    func digit(at index: Int) -> String {
        if index < code.count {
            let start = code.index(code.startIndex, offsetBy: index)
            return String(code[start])
        }
        return ""
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.timerActive = false
            }
        }
    }
    
    func resendCode() {
        timeRemaining = 60
        timerActive = true
        startTimer()
    }
}
