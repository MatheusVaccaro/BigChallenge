//
//  Task+Extension.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension Task {
    var allTags: [Tag] {
        return tags!.allObjects as! [Tag] //swiftlint:disable:this force_cast
    }
    
    var minDate: Date {
        var dates: [Date] = []
        
        if let dueDate = dueDate { dates.append(dueDate) }
        dates.append(contentsOf: allTags
            .map { $0.dueDate }
            .filter { $0 != nil } as! [Date]) //swiftlint:disable:this force_cast
        
        return dates.min()!
    }
    
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
