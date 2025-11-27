//
//  CustomizationModels.swift
//  QuickBite App
//
//  Created by jessica tedja on 21/11/25.
//

import Foundation

struct CustomizationGroup: Identifiable {
    let id = UUID()
    var title: String
    var selectionType: String
    var options: [CustomizationOption]
}

struct CustomizationOption: Identifiable {
    let id = UUID()
    var name: String
    var additionalPrice: Int
}
