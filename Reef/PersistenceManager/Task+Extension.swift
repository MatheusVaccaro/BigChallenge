//
//  Task+Extension.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

extension Task {
    var notificationOptions: NotificationOptions {
        get {
            let frequency = NotificationOptions.Frequency(rawValue: self.frequency) ?? .none
            let notificationOptions = NotificationOptions(triggerDate: self.dueDate,
                                                          frequency: frequency)
            return notificationOptions
        }
        
        set {
            self.dueDate = newValue.triggerDate
            self.frequency = newValue.frequency.rawValue
        }
    }
}

struct NotificationOptions {
    let triggerDate: Date?
    let frequency: Frequency
    
    enum Frequency: Int16 {
        case none
        case weekly
        case biweekly
        case monthly
        case custom
    }
}
