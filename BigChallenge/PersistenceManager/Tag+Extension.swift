//
//  Tag+Extension.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 15/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension Tag {    
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
