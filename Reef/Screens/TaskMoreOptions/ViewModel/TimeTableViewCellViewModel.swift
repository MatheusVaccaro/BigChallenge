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
        if let date = try? calendarDate.value() {
            let subTitleDate = Calendar.current.date(from: date)!
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "d MMM hh:mm"
            let subtitle = dateFormatter.string(from: subTitleDate)
            
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
        if date.value != nil {
            return subtitle
        } else {
            return nil
        }
    }
}
