//
//  DateInputViewModel+Extension.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 15/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

extension DateInputViewModel {
    convenience init(with tag: Tag?) {
        guard let tag = tag else {
            self.init()
            return
        }
        
        if let triggerDate = tag.notificationOptions.triggerDate {
            let date = Calendar.current.calendarDate(from: triggerDate)
            let timeOfDay = Calendar.current.timeOfDay(from: triggerDate)
            let frequency = tag.notificationOptions.frequency
            self.init(calendarDate: date, timeOfDay: timeOfDay, frequency: frequency)
            
        } else {
            self.init()
        }
    }
    
    convenience init(with task: Task?) {
        guard let task = task, let dueDate = task.dueDate else {
            self.init()
            return
        }
        
        let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: dueDate)
        self.init(calendarDate: calendarDate, timeOfDay: timeOfDay, frequency: nil)
    }
}
