//
//  HeaderBackgroundView.swift
//  QuickBite App
//
//  Created by jessica tedja on 04/11/25.
//

import SwiftUI

struct HeaderBackgroundView: View {
    var height: CGFloat = 190
    var imageYOffset: CGFloat = -22

    var body: some View {
        GeometryReader { geo in
            Image("HeaderBackground")
                .resizable()
                .scaledToFill()
                .frame(
                    width: geo.size.width,
                    height: (height + geo.safeAreaInsets.top) - imageYOffset
                )
                .clipped()
                .offset(y: imageYOffset)
                .ignoresSafeArea(edges: .top)
        }
        .frame(height: height)
    }
}
