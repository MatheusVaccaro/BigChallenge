//
//  MoreOptionsViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import ReefKit

protocol MoreOptionsViewModelDelegate: class {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion, arriving: Bool)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: DateComponents)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency)
}

protocol MoreOptionsViewModelUIDelegate: class {
    func shouldUpdateTableView()
}

class MoreOptionsViewModel {
    
    init() {
        locationInputViewModel = LocationInputViewModel()
        dateInputViewModel = DateInputViewModel()

        locationInputViewModel.delegate = self
        dateInputViewModel.delegate = self
    }
    
    func edit(task: Task?) {
        locationInputViewModel.task = task
        dateInputViewModel.task = task
        delegate.shouldUpdateTableView()
    }
    
    weak var outputDelegate: MoreOptionsViewModelDelegate?
    weak var delegate: MoreOptionsViewModelUIDelegate!
    
    let locationInputViewModel: LocationInputViewModel
    let dateInputViewModel: DateInputViewModel
    
    let numberOfSections = 1
    let numberOfRows = 2
}

extension MoreOptionsViewModel: LocationInputDelegate {    
    func locationInput(_ locationInputViewModel: LocationInputViewModel, didFind location: CLCircularRegion, arriving: Bool) {
        outputDelegate?.locationInput(locationInputViewModel, didFind: location, arriving: arriving)
    }
}

extension MoreOptionsViewModel: DateInputViewModelDelegate {

    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: DateComponents) {
        outputDelegate?.dateInputViewModel(dateInputViewModel, didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        outputDelegate?.dateInputViewModel(dateInputViewModel, didSelectFrequency: frequency)
    }
}
