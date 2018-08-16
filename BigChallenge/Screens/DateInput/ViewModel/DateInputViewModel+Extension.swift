//
//  DateInputViewModel+Extension.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 15/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension DateInputViewModel {
    //TODO default day when date is removable
    convenience init(with task: Task?) {
        let timeOfDay = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        guard let task = task else {
            self.init(timeOfDay: timeOfDay)
            return
        }
        
        if let triggerDate = task.notificationOptions.triggerDate {
            let date = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
            let timeOfDay = Calendar.current.dateComponents([.hour, .minute, .second], from: triggerDate)
            let frequency = task.notificationOptions.frequency
            self.init(date: date, timeOfDay: timeOfDay, frequency: frequency)
            
        } else {
            self.init(timeOfDay: timeOfDay)
        }
    }
    
    convenience init(with tag: Tag?) {
        let timeOfDay = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        guard let tag = tag else {
            self.init(timeOfDay: timeOfDay)
            return
        }
        
        if let triggerDate = tag.notificationOptions.triggerDate {
            let date = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
            let timeOfDay = Calendar.current.dateComponents([.hour, .minute, .second], from: triggerDate)
            let frequency = tag.notificationOptions.frequency
            self.init(date: date, timeOfDay: timeOfDay, frequency: frequency)
            
        } else {
            self.init(timeOfDay: timeOfDay)
        }
    }
}
