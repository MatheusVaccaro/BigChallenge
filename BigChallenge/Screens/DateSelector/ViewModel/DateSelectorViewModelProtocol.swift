//
//  DateSelectorViewModelProtocol.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol DateSelectorViewModelProtocol {
    var delegate: DateSelectorViewModelDelegate? { get set }
    
    var date: DateComponents? { get }
    var timeOfDay: DateComponents? { get }
    var frequency: NotificationOptions.Frequency? { get }
    
    func selectDate(_ date: DateComponents)
    func selectTimeOfDay(_ timeOfDay: DateComponents)
    func select(frequency: NotificationOptions.Frequency)
    
    func selectTomorrow()
    func selectNextWeek()
    func selectNextMonth()
}
