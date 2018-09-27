//
//  TimeTableViewCellViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift

extension IconCellPresentable where Self: DateInputViewModelProtocol {
    
    var title: String {
        return Strings.Details.TimeCell.title
    }
    
    var subtitle: String {
        
        if let lastObservedCalendarDate = try? calendarDate.value(), let calendarDate = lastObservedCalendarDate,
           let lastObservedTimeOfDay = try? timeOfDay.value(), let timeOfDay = lastObservedTimeOfDay,
    	   let date = Calendar.current.combine(calendarDate: calendarDate, andTimeOfDay: timeOfDay) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let subtitle = dateFormatter.string(from: date)
            
            return subtitle
            
        } else {
            return Strings.Details.TimeCell.subtitle
        }
    }
    
    var imageName: String {
        return "dateIcon"
    }
    
    var voiceOverHint: String {
        return Strings.Details.TimeCell.subtitle
    }
    
    var voiceOverValue: String? {
        if wasLastDateNonnil {
            return subtitle
        } else {
            return nil
        }
    }
}
