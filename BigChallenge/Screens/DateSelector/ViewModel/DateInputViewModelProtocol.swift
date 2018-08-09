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
    var delegate: DateSelectorViewModelDelegate? { get set }
    
    var date: Variable<DateComponents?> { get }
    var timeOfDay: Variable<DateComponents?> { get }
    var frequency: Variable<NotificationOptions.Frequency?> { get }
    
    var dateObservable: Observable<DateComponents?> { get }
    var timeOfDayObservable: Observable<DateComponents?> { get }
    var frequencyObservable: Observable<NotificationOptions.Frequency?> { get }
    
    func selectDate(_ date: DateComponents)
    func selectTimeOfDay(_ timeOfDay: DateComponents)
    func select(frequency: NotificationOptions.Frequency)
    
    func selectTomorrow()
    func selectNextWeek()
    func selectNextMonth()
}
