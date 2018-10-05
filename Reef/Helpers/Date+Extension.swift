//
//  Date+Extension.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 21/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension Date {
    static func now() -> Date {
		return DateGenerator.shared?.now ?? Date()
    }
    
    func snappedToNextHour() -> Date {
        let datePlusOneHour = Calendar.current.date(byAdding: .hour, value: 1, to: self)!
        let nextHourComponent = Calendar.current.dateComponents([.hour], from: datePlusOneHour)
        let nextHour = Calendar.current.nextDate(after: self, matching: nextHourComponent, matchingPolicy: .nextTime)!

        return nextHour
    }
    
    func string(with format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        let dateStr = dateFormatter.string(from: self)
        
        return dateStr
    }
    
    var accessibilityDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        let dateStr = dateFormatter.string(from: self)
        
        return dateStr
    }
}

class DateGenerator {
    
    static var shared: DateGenerator?
    let now: Date
    
    init(currentDate: Date) {
        self.now = currentDate
    }
}
