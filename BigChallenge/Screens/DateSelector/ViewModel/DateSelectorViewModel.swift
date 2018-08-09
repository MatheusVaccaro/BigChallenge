//
//  DateSelectorViewModel.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift

class DateSelectorViewModel: DateSelectorViewModelProtocol {
    
    weak var delegate: DateSelectorViewModelDelegate?
    
    private(set) var date: Variable<DateComponents?>
    private(set) var timeOfDay: Variable<DateComponents?>
    private(set) var frequency: Variable<NotificationOptions.Frequency?>
    
    var dateObservable: Observable<DateComponents?> {
        return date.asObservable()
    }
    var timeOfDayObservable: Observable<DateComponents?> {
        return timeOfDay.asObservable()
    }
    var frequencyObservable: Observable<NotificationOptions.Frequency?> {
        return frequency.asObservable()
    }
    
    init(delegate: DateSelectorViewModelDelegate? = nil) {
        self.delegate = delegate
        
        self.date = Variable(nil)
        self.timeOfDay = Variable(nil)
        self.frequency = Variable(nil)
    }
    
    func selectDate(_ date: DateComponents) {
        guard let day = date.day, let month = date.month, let year = date.year else { return }
        
        let dateComponents = DateComponents(year: year, month: month, day: day)
        
        self.date.value = dateComponents
        delegate?.dateSelectorViewModel(self, didSelectDate: dateComponents)
    }
    
    func selectTimeOfDay(_ timeOfDay: DateComponents) {
        guard let hour = timeOfDay.hour, let minute = timeOfDay.minute else { return }
        
        let dateComponents = DateComponents(hour: hour, minute: minute)
        
        self.timeOfDay.value = dateComponents
        delegate?.dateSelectorViewModel(self, didSelectTimeOfDay: dateComponents)
    }
    
    func select(frequency: NotificationOptions.Frequency) {
    	self.frequency.value = frequency
        delegate?.dateSelectorViewModel(self, didSelect: frequency)
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

protocol DateSelectorViewModelDelegate: class {
    //swiftlint:disable next line_length
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didFinishSelecting notificationOptions: NotificationOptions)
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelectDate date: DateComponents)
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelectTimeOfDay timeOfDay: DateComponents)
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelect frequency: NotificationOptions.Frequency)
}
