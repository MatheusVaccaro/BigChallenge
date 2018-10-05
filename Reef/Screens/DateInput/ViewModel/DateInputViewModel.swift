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
    private let disposeBag = DisposeBag()
    
    private(set) var calendarDate: BehaviorSubject<DateComponents?>
    private(set) var timeOfDay: BehaviorSubject<DateComponents?>
    private(set) var date: Observable<Date?>
    private(set) var frequency: BehaviorSubject<NotificationOptions.Frequency?>
    
    private(set) var wasLastDateNonnil: Bool
    
    private(set) var tomorrowShortcutText: BehaviorSubject<String>
    private(set) var nextWeekShortcutText: BehaviorSubject<String>
    private(set) var nextMonthShortcutText: BehaviorSubject<String>
    
    private(set) var twoHoursFromNowShortcutText: BehaviorSubject<String>
    private(set) var thisEveningShortcutText: BehaviorSubject<String>
    private(set) var nextMorningShortcutText: BehaviorSubject<String>
    
    required init(calendarDate: DateComponents? = nil, timeOfDay: DateComponents? = nil,
         frequency: NotificationOptions.Frequency? = nil,
         delegate: DateInputViewModelDelegate? = nil) {
        
        self.delegate = delegate
        
        self.calendarDate = BehaviorSubject(value: calendarDate)
        self.timeOfDay = BehaviorSubject(value: timeOfDay)
        self.frequency = BehaviorSubject(value: frequency)
        
        self.wasLastDateNonnil = false
        
        self.tomorrowShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.tomorrowShortcut)
        self.nextWeekShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.nextWeekShortcut)
        self.nextMonthShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.nextMonthShortcut)
        
        self.twoHoursFromNowShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.twoHoursFromNowShortcut)
        self.thisEveningShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.thisEveningShortcut)
        self.nextMorningShortcutText = BehaviorSubject<String>(value: Strings.DateInputView.nextMorningShortcut)
        
        self.date = Observable
            .combineLatest(self.calendarDate, self.timeOfDay) { (calendarDate, timeOfDay) -> Date? in
                guard let calendarDate = calendarDate, let timeOfDay = timeOfDay else {
                    return nil
                }
                let date = Calendar.current.combine(calendarDate: calendarDate, andTimeOfDay: timeOfDay)
                
                return date
            }
        
        date.subscribe(onNext: { date in
        		self.wasLastDateNonnil = date != nil
        	})
            .disposed(by: disposeBag)
        
        setupDateDelegate()

        #if DEBUG
        print("+++ INIT DateInputViewModel")
        #endif
    }
    
    convenience init(date: Date = Date.now(),
                     frequency: NotificationOptions.Frequency? = nil,
                     delegate: DateInputViewModelDelegate? = nil) {
        
        let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: date)
        
        self.init(calendarDate: calendarDate, timeOfDay: timeOfDay, frequency: frequency, delegate: delegate)
    }
    
    #if DEBUG
    deinit {
        print("--- DEINIT DateInputViewModel")
    }
    #endif
    
    private func setupDateDelegate() {
        date.subscribe(onNext: { date in
                self.delegate?.dateInputViewModel(self, didSelectDate: date)
            })
            .disposed(by: disposeBag)
    }
    
    func selectCalendarDate(_ calendarDate: DateComponents?) {
        guard let day = calendarDate?.day, let month = calendarDate?.month, let year = calendarDate?.year else {
                self.calendarDate.onNext(nil)
                return
        }
        
        let calendarDateComponent = DateComponents(year: year, month: month, day: day)
        
        self.calendarDate.onNext(calendarDateComponent)
    }
    
    func selectTimeOfDay(_ timeOfDay: DateComponents?) {
        guard let hour = timeOfDay?.hour, let minute = timeOfDay?.minute else {
            self.timeOfDay.onNext(nil)
            return
        }
        
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
        
        selectCalendarDate(tomorrowComponents)
    }
    
    func selectNextWeek() {
        let today = Date.now()
        guard let nextWeek = Calendar.current.date(byAdding: DateComponents(day: 7),
                                                   to: today, wrappingComponents: false) else { return }
        
        let nextWeekComponents = Calendar.current.dateComponents([.year, .month, .day], from: nextWeek)
        selectCalendarDate(nextWeekComponents)
    }
    
    func selectNextMonth() {
        let today = Date.now()
        guard let nextMonth = Calendar.current.date(byAdding: DateComponents(day: 30),
                                                    to: today, wrappingComponents: false) else { return }
        
        let nextMonthComponents = Calendar.current.dateComponents([.year, .month, .day], from: nextMonth)
        selectCalendarDate(nextMonthComponents)
    }
    
    func selectTwoHoursFromNow() {
        let today = Date.now()
        guard let twoHoursFromNow = Calendar.current.date(byAdding: DateComponents(hour: 2), to: today) else { return }
        
        let twoHoursFromNowDateComponents = Calendar.current.calendarDate(from: twoHoursFromNow)
        
        let twoHoursFromNowTimeComponents = Calendar.current.timeOfDay(from: twoHoursFromNow)
        
        selectCalendarDate(twoHoursFromNowDateComponents)
        selectTimeOfDay(twoHoursFromNowTimeComponents)
    }
    
    func selectThisEvening() {
        let today = Date.now()
        let todaysEvening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: today)!
        
        let date = today < todaysEvening ? todaysEvening : Calendar.current.date(byAdding: DateComponents(hour: 1),
                                                                                 to: today)

        guard let thisEvening = date else { return }
        
        let thisEveningDateComponents = Calendar.current.calendarDate(from: thisEvening)
        let thisEveningTimeComponents = Calendar.current.timeOfDay(from: thisEvening)
        
        selectCalendarDate(thisEveningDateComponents)
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

        let nextMorningDateComponents = Calendar.current.calendarDate(from: nextMorning)
        let nextMorningTimeComponents = Calendar.current.timeOfDay(from: nextMorning)
        
        selectCalendarDate(nextMorningDateComponents)
        selectTimeOfDay(nextMorningTimeComponents)
    }
    
}

protocol DateInputViewModelDelegate: class {
    //swiftlint:disable next line_length
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: Date?)
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency)
}

extension DateInputViewModel: CalendarViewAccessibilityProvider {
    func accessibilityValue() -> String? {
        if let lastObservedCalendarDate = try? calendarDate.value(),
            let calendarDate = lastObservedCalendarDate,
            let date = Calendar.current.date(from: calendarDate) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let dateDescription = dateFormatter.string(from: date)
            
            return dateDescription
        } else {
            return ""
        }
    }
    
    func scrollDate(forwards: Bool) {
        if try! calendarDate.value() == nil {
            selectCalendarDate(Calendar.current.dateComponents([.year, .month, .day], from: Date()))
        }
        
        let current = Calendar.current.date(from: try! calendarDate.value()!)!
            
        var next = DateComponents()
        
        if forwards {
            let aDayFromCurrent =
                Calendar.current.date(byAdding: .day, value: 1, to: current)!
            next = Calendar.current.calendarDate(from: aDayFromCurrent)
        } else {
            let aDayBeforeCurrent =
                Calendar.current.date(byAdding: .day, value: -1, to: current)!
            next = Calendar.current.calendarDate(from: aDayBeforeCurrent)
        }
        
        selectCalendarDate(next)
    }
    
    func scrollMonth(forwards: Bool) {
        if try! calendarDate.value() == nil {
            selectCalendarDate(Calendar.current.dateComponents([.year, .month, .day], from: Date()))
        }
        
        let current = Calendar.current.date(from: try! calendarDate.value()!)!
        
        var next = DateComponents()
        
        if forwards {
            let aMonthFromCurrent =
                Calendar.current.date(byAdding: .month, value: 1, to: current)!
            next = Calendar.current.calendarDate(from: aMonthFromCurrent)
        } else {
            let aMonthBeforeCurrent =
                Calendar.current.date(byAdding: .month, value: -1, to: current)!
            next = Calendar.current.calendarDate(from: aMonthBeforeCurrent)
        }
        
        selectCalendarDate(next)
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
        // value did change ????????????
    }
}
