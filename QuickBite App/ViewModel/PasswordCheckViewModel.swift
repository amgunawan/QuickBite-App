//
//  PasswordCheckViewModel.swift
//  QuickBite
//
//  Created by Angela on 05/11/25.
//

import SwiftUI
import Combine

class PasswordCheckViewModel: ObservableObject {
    @Published var password: String = ""
    
    var hasValidLength: Bool {
        password.count >= 8 && password.count <= 20
    }
    
    var hasLetterAndNumber: Bool {
        let letter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let number = password.range(of: "[0-9]", options: .regularExpression) != nil
        return letter && number
    }
    
    var hasSpecialCharacter: Bool {
        password.range(of: "[#?!@$%^&*.,;:<>_+=-]", options: .regularExpression) != nil
    }
    
    var isPasswordValid: Bool {
        hasValidLength && hasLetterAndNumber && hasSpecialCharacter
    }
}
