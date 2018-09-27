//
//  Calendar+Extension.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension Calendar {
    func date(from dateComponents: DateComponents?) -> Date? {
        guard let dateComponents = dateComponents else { return nil }
        
        return date(from: dateComponents)
    }
    
    func calendarDate(from date: Date) -> DateComponents {
        let calendarDate = dateComponents([.year, .month, .day], from: date)
        
        return calendarDate
    }
    
    func timeOfDay(from date: Date) -> DateComponents {
        let timeOfDay = dateComponents([.hour, .minute, .second], from: date)
        
        return timeOfDay
    }
    
    func splitCalendarDateAndTimeOfDay(from date: Date) -> (calendarDate: DateComponents, timeOfDay: DateComponents) {
        return (calendarDate(from: date), timeOfDay(from: date))
    }
    
    func combine(calendarDate calendarDateComponents: DateComponents,
                 andTimeOfDay timeOfDayComponents: DateComponents) -> Date? {
        
//        let dateComponents = dateComponents ?? DateComponents()
//        let timeOfDayComponents = timeOfDayComponents ?? DateComponents()
        
        var mergedDateComponents = DateComponents()
        mergedDateComponents.year = calendarDateComponents.year
        mergedDateComponents.month = calendarDateComponents.month
        mergedDateComponents.day = calendarDateComponents.day
        
        mergedDateComponents.hour = timeOfDayComponents.hour
        mergedDateComponents.minute = timeOfDayComponents.minute
        mergedDateComponents.second = timeOfDayComponents.second
        
        return date(from: mergedDateComponents)
    }
}
