//
//  DateSelectorViewModel.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//
import UIKit
import ReefKit
import RxSwift

class DateInputViewModel: DateInputViewModelProtocol {
    
    weak var delegate: DateInputViewModelDelegate?
    
    private(set) var calendarDate: BehaviorSubject<DateComponents?>
    private(set) var timeOfDay: BehaviorSubject<DateComponents?>
    private(set) var frequency: BehaviorSubject<NotificationOptions.Frequency?>
    
    private(set) var tomorrowShortcutText: BehaviorSubject<String>
    private(set) var nextWeekShortcutText: BehaviorSubject<String>
    private(set) var nextMonthShortcutText: BehaviorSubject<String>
    
    private(set) var twoHoursFromNowShortcutText: BehaviorSubject<String>
    private(set) var thisEveningShortcutText: BehaviorSubject<String>
    private(set) var nextMorningShortcutText: BehaviorSubject<String>
    
    init(date: DateComponents? = nil,
         timeOfDay: DateComponents? = nil,
         frequency: NotificationOptions.Frequency? = nil,
         delegate: DateInputViewModelDelegate? = nil) {
        
        self.delegate = delegate
        
        self.calendarDate = BehaviorSubject(value: date)
        self.timeOfDay = BehaviorSubject(value: timeOfDay)
        self.frequency = BehaviorSubject(value: frequency)
        
        self.tomorrowShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.tomorrowShortcut)
        self.nextWeekShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.nextWeekShortcut)
        self.nextMonthShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.nextMonthShortcut)
        
        self.twoHoursFromNowShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.twoHoursFromNowShortcut)
        self.thisEveningShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.thisEveningShortcut)
        self.nextMorningShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.nextMorningShortcut)
        
        #if DEBUG
        print("+++ INIT DateInputViewModel")
        #endif
    }
    
    convenience init() {
        let now = Date.now()
        let timeOfDayNow = Calendar.current.dateComponents([.hour, .minute, .second], from: now)
        let today = Calendar.current.dateComponents([.day, .month, .year], from: now)
        
        self.init(date: today, timeOfDay: timeOfDayNow, frequency: .none)
    }
    
    #if DEBUG
    deinit {
        print("--- DEINIT DateInputViewModel")
    }
    #endif
    
    func selectDate(_ calendarDate: DateComponents) {
        guard let day = calendarDate.day, let month = calendarDate.month, let year = calendarDate.year else { return }
        
        let calendarDateComponent = DateComponents(year: year, month: month, day: day)
        
        self.calendarDate.onNext(calendarDateComponent)
    }
    
    func selectTimeOfDay(_ timeOfDay: DateComponents) {
        guard let hour = timeOfDay.hour, let minute = timeOfDay.minute else { return }
        
        let timeOfDayComponent = DateComponents(hour: hour, minute: minute)
        
        self.timeOfDay.onNext(timeOfDayComponent)
    }
    
    func select(frequency: NotificationOptions.Frequency) {
    	self.frequency.onNext(frequency)
        delegate?.dateInputViewModel(self, didSelectFrequency: frequency)
    }
    
    func selectTomorrow() {
        let today = Date.now()
        guard let tomorrow = Calendar.current.date(byAdding: DateComponents(day: 1),
                                                   to: today, wrappingComponents: false) else { return }
        
        let tomorrowComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        
        selectDate(tomorrowComponents)
    }
    
    func selectNextWeek() {
        let today = Date.now()
        guard let nextWeek = Calendar.current.date(byAdding: DateComponents(day: 7),
                                                   to: today, wrappingComponents: false) else { return }
        
        let nextWeekComponents = Calendar.current.dateComponents([.year, .month, .day], from: nextWeek)
        selectDate(nextWeekComponents)
    }
    
    func selectNextMonth() {
        let today = Date.now()
        guard let nextMonth = Calendar.current.date(byAdding: DateComponents(day: 30),
                                                    to: today, wrappingComponents: false) else { return }
        
        let nextMonthComponents = Calendar.current.dateComponents([.year, .month, .day], from: nextMonth)
        selectDate(nextMonthComponents)
    }
    
    func selectTwoHoursFromNow() {
        let today = Date.now()
        guard let twoHoursFromNow = Calendar.current.date(byAdding: DateComponents(hour: 2), to: today) else { return }
        
        let twoHoursFromNowDateComponents = Calendar.current.dateComponents([.year, .month, .day],
                                                                            from: twoHoursFromNow)
        let twoHoursFromNowTimeComponents = Calendar.current.dateComponents([.hour, .minute, .second],
                                                                            from: twoHoursFromNow)
        
        selectDate(twoHoursFromNowDateComponents)
        selectTimeOfDay(twoHoursFromNowTimeComponents)
    }
    
    func selectThisEvening() {
        let today = Date.now()
        let todaysEvening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: today)!
        
        let date = today < todaysEvening ? todaysEvening : Calendar.current.date(byAdding: DateComponents(hour: 1),
                                                                                 to: today)

        guard let thisEvening = date else { return }
        
        let thisEveningDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: thisEvening)
        let thisEveningTimeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: thisEvening)
        
        selectDate(thisEveningDateComponents)
        selectTimeOfDay(thisEveningTimeComponents)
    }
    
    func selectNextMorning() {
        let today = Date.now()
        
        let currentHour = Calendar.current.component(.hour, from: today)
        
        let date: Date?
        if currentHour < 8 {
            date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: today)
        } else {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let tomorrowMorning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow)
            date = tomorrowMorning
        }
        
        guard let nextMorning = date else { return }

        let nextMorningDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: nextMorning)
        let nextMorningTimeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: nextMorning)
        
        selectDate(nextMorningDateComponents)
        selectTimeOfDay(nextMorningTimeComponents)
    }
    
}

protocol DateInputViewModelDelegate: class {
    //swiftlint:disable next line_length
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: Date)
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency)
}
