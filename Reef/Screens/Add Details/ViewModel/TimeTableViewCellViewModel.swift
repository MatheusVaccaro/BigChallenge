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
        return Strings.DateInputView.Cell.title
    }
    
    var subtitle: String {
        
        var subtitle = ""
        
        if let lastObservedCalendarDate = try? calendarDate.value(), let calendarDate = lastObservedCalendarDate,
           let date = Calendar.current.date(from: calendarDate) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let calendarDateString = dateFormatter.string(from: date)
            subtitle += calendarDateString
        }
        
        if let lastObservedTimeOfDay = try? timeOfDay.value(), let timeOfDay = lastObservedTimeOfDay,
           let date = Calendar.current.date(from: timeOfDay) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let timeOfDayString = dateFormatter.string(from: date)
            subtitle += " " + timeOfDayString
        }
        
        subtitle = subtitle.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        
        if subtitle.isEmpty {
            return Strings.DateInputView.Cell.subtitle
        } else {
            return subtitle
        }
    }
    
    var imageName: String {
        return "dateIcon"
    }
    
    var voiceOverHint: String {
        return Strings.DateInputView.Cell.subtitle
    }
    
    var voiceOverValue: String? {
        if wasLastDateNonnil {
            return subtitle
        } else {
            return nil
        }
    }
}
