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
        return Strings.MoreOptionsScreen.TimeCell.title
    }
    
    var subtitle: String {
        if let calendarDate = try? calendarDate.value(), let timeOfDay = try? timeOfDay.value(),
            let date = Calendar.current.combine(calendarDate: calendarDate, andTimeOfDay: timeOfDay) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "d MMM hh:mm"
            let subtitle = dateFormatter.string(from: date)
            
            return subtitle
        } else {
            return Strings.MoreOptionsScreen.TimeCell.subtitle
        }
    }
    
    var imageName: String {
        return "dateIcon"
    }
    
    var voiceOverHint: String {
        return Strings.MoreOptionsScreen.TimeCell.subtitle
    }
    
    var voiceOverValue: String? {
        if wasLastDateNonnil {
            return subtitle
        } else {
            return nil
        }
    }
}
