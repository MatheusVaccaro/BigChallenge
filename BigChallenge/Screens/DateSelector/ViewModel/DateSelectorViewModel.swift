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
    
    private(set) var date: DateComponents?
    private(set) var timeOfDay: DateComponents?
    private(set) var frequency: NotificationOptions.Frequency?
    
    init(delegate: DateSelectorViewModelDelegate? = nil) {
        self.delegate = delegate
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
