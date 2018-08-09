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
    
    func selectDate(_ date: DateComponents) { }
    func selectTimeOfDay(_ timeOfDay: DateComponents) { }
    func select(frequency: NotificationOptions.Frequency) {}
    
    func selectTomorrow() { }
    func selectNextWeek() { }
    func selectNextMonth() { }
}

protocol DateSelectorViewModelDelegate: class {
    //swiftlint:disable next line_length
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didFinishSelecting notificationOptions: NotificationOptions)
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelectDate date: DateComponents)
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelectTimeOfDay timeOfDay: DateComponents)
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelect frequency: NotificationOptions.Frequency)
}
