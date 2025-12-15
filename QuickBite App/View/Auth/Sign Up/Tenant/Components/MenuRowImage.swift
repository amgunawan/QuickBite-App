//
//  MenuRowImage.swift
//  QuickBite
//
//  Created by student on 15/12/25.
//

import SwiftUI

struct MenuRowImage: View {

    let imageURL: String?

    var body: some View {
        AsyncImage(url: URL(string: imageURL ?? "")) { phase in
            content(for: phase)
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func content(for phase: AsyncImagePhase) -> some View {
        if let img = phase.image {
            img.resizable().scaledToFill()
        } else if phase.error != nil {
            Image("placeholder")
                .resizable()
                .scaledToFill()
        } else {
            ProgressView()
        }
    }
}
