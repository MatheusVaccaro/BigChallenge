//
//  DateSelectorViewModelProtocol.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift

protocol DateInputViewModelProtocol {
    var delegate: DateInputViewModelDelegate? { get set }
    
    var date: Variable<DateComponents?> { get }
    var timeOfDay: Variable<DateComponents?> { get }
    var frequency: Variable<NotificationOptions.Frequency?> { get }
    
    func selectDate(_ date: DateComponents)
    func selectTimeOfDay(_ timeOfDay: DateComponents)
    func select(frequency: NotificationOptions.Frequency)
    
    // MARK: - Date shortcuts
    var tomorrowShortcutText: Variable<String> { get }
    var nextWeekShortcutText: Variable<String> { get }
    var nextMonthShortcutText: Variable<String> { get }
    
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
