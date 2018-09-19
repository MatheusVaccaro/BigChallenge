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
            let date = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
            let timeOfDay = Calendar.current.dateComponents([.hour, .minute, .second], from: triggerDate)
            let frequency = tag.notificationOptions.frequency
            self.init(date: date, timeOfDay: timeOfDay, frequency: frequency)
            
        } else {
            self.init()
        }
    }
}
