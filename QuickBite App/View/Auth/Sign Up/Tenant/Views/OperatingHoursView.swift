//
//  OperatingHoursView.swift
//  QuickBite
//
//  Created by student on 12/11/25.
//

import SwiftUI

struct OperatingHoursView: View {
    @State private var openingTime = Date()
    @State private var closingTime = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            RegistrationHeader(step: 3,
                               title: "Operating Hours",
                               subtitle: "Set your daily operating times.")
            
            Form {
                DatePicker("Opening Time", selection: $openingTime, displayedComponents: .hourAndMinute)
                DatePicker("Closing Time", selection: $closingTime, displayedComponents: .hourAndMinute)
            }
            
            NavigationLink(destination: ConfirmationView()) {
                OrangeButton(title: "Continue", action: {}, enabled: true)
            }
            .padding()
        }
    }
}

#Preview {
    OperatingHoursView()
}
