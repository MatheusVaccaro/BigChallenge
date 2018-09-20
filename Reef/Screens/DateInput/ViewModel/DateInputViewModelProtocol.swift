//
//  DateSelectorViewModelProtocol.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift

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
    
    func selectCalendarDate(_ calendarDate: DateComponents)
    func selectTimeOfDay(_ timeOfDay: DateComponents)
    func select(frequency: NotificationOptions.Frequency)
    
    // MARK: - Date shortcuts
    var tomorrowShortcutText: BehaviorSubject<String> { get }
    var nextWeekShortcutText: BehaviorSubject<String> { get }
    var nextMonthShortcutText: BehaviorSubject<String> { get }
    
    var twoHoursFromNowShortcutText: BehaviorSubject<String> { get }
    var thisEveningShortcutText: BehaviorSubject<String> { get }
    var nextMorningShortcutText: BehaviorSubject<String> { get }
    
    func selectTomorrow()
    func selectNextWeek()
    func selectNextMonth()
    
    func selectTwoHoursFromNow()
    func selectThisEvening()
    func selectNextMorning()
}
