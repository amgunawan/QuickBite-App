//
//  CalendarEvent.swift
//  QuickBite
//
//  Created by student on 12/12/25.
//

import Foundation

struct CalendarEvent: Identifiable{
    let id = UUID()
    let title: String
    let startTime: Date
    let endTime: Date
}
