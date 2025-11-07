//
//  SplashView.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//

import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void
    
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var logoOffset: CGFloat = 0
    @State private var displayedText = ""
    @State private var splashOpacity: Double = 1.0
    
    private let fullText = "QuickBite"
    
    var body: some View {
        ZStack {
            Image("SplashBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(splashOpacity)
            
            VStack(spacing: 0) {
                Image("Logo QuickBite")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: logoOffset)
                    .onAppear {
                        playAnimation()
                    }
                
                Text(displayedText)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(displayedText.isEmpty ? 0 : 1)
                    .offset(y: -10)
            }
            .opacity(splashOpacity)
        }
    }
    
    private func playAnimation() {
        // Step 1: Logo muncul
        withAnimation(.easeInOut(duration: 1.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Step 2: Setelah logo selesai, mulai typewriter
        let delayBeforeTyping = 1.2
        var charIndex = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeTyping) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                logoOffset = -30
            }
        }
        
        for letter in fullText {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeTyping + charIndex * 0.15) {
                displayedText.append(letter)
                
                // Step 3: Setelah selesai mengetik
                if displayedText.count == fullText.count {
                    // Tambahkan delay 0.5 detik sebelum fade out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            splashOpacity = 0.0
                        }
                        
                        // Step 4: Panggil onFinish() setelah fade out selesai
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onFinish()
                        }
                    }
                }
            }
            charIndex += 1
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
