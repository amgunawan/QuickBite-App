//
//  ActivityView.swift
//  QuickBite App
//
//  Created by jessica tedja on 02/11/25.
//

import SwiftUI

struct ActivityView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Activity")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            
            
            Spacer()
        }
    }
}

#Preview {
    ActivityView()
}
