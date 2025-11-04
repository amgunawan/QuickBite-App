//
//  HeaderBackgroundView.swift
//  QuickBite App
//
//  Created by jessica tedja on 04/11/25.
//

import SwiftUI

enum HeaderTitlePlacement { case top, bottom }

struct HeaderBackgroundView: View {
    var title: String
    var height: CGFloat = 190
    var imageYOffset: CGFloat = -22
    var titlePlacement: HeaderTitlePlacement = .bottom
    var bottomTitleOffset: CGFloat = 52

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
                .overlay(alignment: .topLeading) {
                    if titlePlacement == .top {
                        Text(title)
                            .font(.largeTitle.bold())
                            .foregroundColor(.black.opacity(0.85))
                            .padding(.horizontal, 20)
                            .padding(.top, geo.safeAreaInsets.top + 12)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    if titlePlacement == .bottom {
                        Text(title)
                            .font(.largeTitle.bold())
                            .foregroundColor(.black.opacity(0.85))
                            .padding(.horizontal, 20)
                            .padding(.bottom, bottomTitleOffset)
                    }
                }
        }
        .frame(height: height)
    }
}
