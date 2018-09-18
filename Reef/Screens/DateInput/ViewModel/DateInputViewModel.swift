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
    
    private(set) var date: Variable<DateComponents?>
    private(set) var timeOfDay: Variable<DateComponents?>
    private(set) var frequency: Variable<NotificationOptions.Frequency?>
    
    private(set) var tomorrowShortcutText: Variable<String>
    private(set) var nextWeekShortcutText: Variable<String>
    private(set) var nextMonthShortcutText: Variable<String>
    
    private(set) var twoHoursFromNowShortcutText: BehaviorSubject<String>
    private(set) var thisEveningShortcutText: BehaviorSubject<String>
    private(set) var nextMorningShortcutText: BehaviorSubject<String>
    
    var task: Task? {
        didSet {
            if let date = task?.dueDate {
                dateComponents = Calendar.current.dateComponents(Set([.year, .month, .day, .hour, .minute]), from: date)
            }
        }
    }
    
    init(date: DateComponents? = nil,
         timeOfDay: DateComponents? = nil,
         frequency: NotificationOptions.Frequency? = nil,
         delegate: DateInputViewModelDelegate? = nil) {
        
        self.delegate = delegate
        
        self.date = Variable(date)
        self.timeOfDay = Variable(timeOfDay)
        self.frequency = Variable(frequency)
        
        self.tomorrowShortcutText = Variable<String>(Strings.DateInputView.tomorrowShortcut)
        self.nextWeekShortcutText = Variable<String>(Strings.DateInputView.nextWeekShortcut)
        self.nextMonthShortcutText = Variable<String>(Strings.DateInputView.nextMonthShortcut)
        
        self.twoHoursFromNowShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.twoHoursFromNowShortcut)
        self.thisEveningShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.thisEveningShortcut)
        self.nextMorningShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.nextMorningShortcut)
        
        print("+++ INIT DateInputViewModel")
    }
    
    deinit {
        print("--- DEINIT DateInputViewModel")
    }
    
    private var dateComponents: DateComponents = Calendar.current.dateComponents(Set([.year, .month, .day, .hour, .minute]), from: Date()) //TODO: did set: configure calendar from task
    
    func selectDate(_ date: DateComponents) {
        guard let day = date.day, let month = date.month, let year = date.year else { return }
        
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        self.date.value = dateComponents
        delegate?.dateInputViewModel(self, didSelectDate: dateComponents)
    }
    
    func selectTimeOfDay(_ timeOfDay: DateComponents) {
        guard let hour = timeOfDay.hour, let minute = timeOfDay.minute else { return }
        
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        self.timeOfDay.value = dateComponents
        delegate?.dateInputViewModel(self, didSelectDate: dateComponents)
    }
    
    func select(frequency: NotificationOptions.Frequency) {
    	self.frequency.value = frequency
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
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents)
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency)
}
