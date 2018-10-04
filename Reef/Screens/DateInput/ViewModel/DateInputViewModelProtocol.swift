//
//  DateSelectorViewModelProtocol.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift
/**
 A view model for a date picking screen.
 To use this view model, either subscribe to a specific value (```calendarDate``` or ```timeOfDay```) or subscribe to ```date```, which is the last two combined values of ```calendarDate``` and ```timeOfDay```.
 Alternatively, you can listen to the changes made to ```date``` using the delegate.
 
 - Note: "Calendar date" refers to a DateComponents object with only year, month and day values;
 while "Time of day" refers to a DateComponents object with only hour, minute and seconds values.
 */
protocol DateInputViewModelProtocol: IconCellPresentable {
    var delegate: DateInputViewModelDelegate? { get set }
    
    /** The last year, month and day values selected. */
    var calendarDate: BehaviorSubject<DateComponents?> { get }
    /** The last hour, minute and second values selected */
    var timeOfDay: BehaviorSubject<DateComponents?> { get }
    /** The last calendar date and time of day selected, combined. */
    var date: Observable<Date?> { get }
    /** The last frequency value selected. */
    var frequency: BehaviorSubject<NotificationOptions.Frequency?> { get }
    
    /** Convenience property to bypass RX. */
    var wasLastDateNonnil: Bool { get }
    
    func selectCalendarDate(_ calendarDate: DateComponents?)
    func selectTimeOfDay(_ timeOfDay: DateComponents?)
    func select(frequency: NotificationOptions.Frequency)
    
    // MARK: - Date shortcuts
    var tomorrowShortcutText: BehaviorSubject<String> { get }
    var nextWeekShortcutText: BehaviorSubject<String> { get }
    var nextMonthShortcutText: BehaviorSubject<String> { get }
    
    var twoHoursFromNowShortcutText: BehaviorSubject<String> { get }
    var thisEveningShortcutText: BehaviorSubject<String> { get }
    var nextMorningShortcutText: BehaviorSubject<String> { get }
    
    init(calendarDate: DateComponents?, timeOfDay: DateComponents?,
    frequency: NotificationOptions.Frequency?,
    delegate: DateInputViewModelDelegate?)
    
    func selectTomorrow()
    func selectNextWeek()
    func selectNextMonth()
    
    func selectTwoHoursFromNow()
    func selectThisEvening()
    func selectNextMorning()
}
