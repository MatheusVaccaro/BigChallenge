//
//  DateSelectorViewModel.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift

class DateInputViewModel: DateInputViewModelProtocol {

    weak var delegate: DateInputViewModelDelegate?
    
    private(set) var date: Variable<DateComponents?>
    private(set) var timeOfDay: Variable<DateComponents?>
    private(set) var frequency: Variable<NotificationOptions.Frequency?>
    
    private(set) var tomorrowShortcutText: Variable<String>
    private(set) var nextWeekShortcutText: Variable<String>
    private(set) var nextMonthShortcutText: Variable<String>
    
    init(delegate: DateInputViewModelDelegate? = nil) {
        self.delegate = delegate
        
        self.date = Variable(nil)
        self.timeOfDay = Variable(nil)
        self.frequency = Variable(nil)
        
        self.tomorrowShortcutText = Variable<String>(Strings.DateInputView.tomorrowShortcut)
        self.nextWeekShortcutText = Variable<String>(Strings.DateInputView.nextWeekShortcut)
        self.nextMonthShortcutText = Variable<String>(Strings.DateInputView.nextMonthShortcut)
    }
    
    func selectDate(_ date: DateComponents) {
        guard let day = date.day, let month = date.month, let year = date.year else { return }
        
        let dateComponents = DateComponents(year: year, month: month, day: day)
        
        self.date.value = dateComponents
        delegate?.dateInputViewModel(self, didSelectDate: dateComponents)
    }
    
    func selectTimeOfDay(_ timeOfDay: DateComponents) {
        guard let hour = timeOfDay.hour, let minute = timeOfDay.minute else { return }
        
        let dateComponents = DateComponents(hour: hour, minute: minute)
        
        self.timeOfDay.value = dateComponents
        delegate?.dateInputViewModel(self, didSelectTimeOfDay: dateComponents)
    }
    
    func select(frequency: NotificationOptions.Frequency) {
    	self.frequency.value = frequency
        delegate?.dateInputViewModel(self, didSelectFrequency: frequency)
    }
    
    func selectTomorrow() {
        let today = Date()
        guard let tomorrow = Calendar.current.date(byAdding: DateComponents(day: 1),
                                                   to: today, wrappingComponents: false) else { return }
        
        let tomorrowComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        
        selectDate(tomorrowComponents)
    }
    
    func selectNextWeek() {
        let today = Date()
        guard let nextWeek = Calendar.current.date(byAdding: DateComponents(day: 7),
                                                   to: today, wrappingComponents: false) else { return }
        
        let nextWeekComponents = Calendar.current.dateComponents([.year, .month, .day], from: nextWeek)
        selectDate(nextWeekComponents)
    }
    
    func selectNextMonth() {
        let today = Date()
        guard let nextMonth = Calendar.current.date(byAdding: DateComponents(day: 30),
                                                    to: today, wrappingComponents: false) else { return }
        
        let nextMonthComponents = Calendar.current.dateComponents([.year, .month, .day], from: nextMonth)
        selectDate(nextMonthComponents)
    }
}

protocol DateInputViewModelDelegate: class {
    //swiftlint:disable next line_length
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents)
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectTimeOfDay timeOfDay: DateComponents)
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency)
}
