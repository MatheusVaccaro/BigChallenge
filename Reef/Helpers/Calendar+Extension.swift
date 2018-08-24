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
    
    func combine(date dateComponents: DateComponents?, andTimeOfDay timeOfDayComponents: DateComponents?) -> Date? {
        let dateComponents = dateComponents ?? DateComponents()
        let timeOfDayComponents = timeOfDayComponents ?? DateComponents()
        
        var mergedDateComponents = DateComponents()
        mergedDateComponents.year = dateComponents.year
        mergedDateComponents.month = dateComponents.month
        mergedDateComponents.day = dateComponents.day
        
        mergedDateComponents.hour = timeOfDayComponents.hour
        mergedDateComponents.minute = timeOfDayComponents.minute
        mergedDateComponents.second = timeOfDayComponents.second
        
        return date(from: mergedDateComponents)
    }
}
