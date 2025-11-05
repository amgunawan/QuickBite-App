//
//  EmailCheckViewModel.swift
//  QuickBite
//
//  Created by Angela on 05/11/25.
//

import SwiftUI
import Combine

class EmailCheckViewModel: ObservableObject {
    @Published var email: String = ""
    
    var isEmailValid: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}
