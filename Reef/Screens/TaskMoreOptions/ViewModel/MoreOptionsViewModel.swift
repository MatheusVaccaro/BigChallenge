//
//  MoreOptionsViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

protocol MoreOptionsViewModelDelegate: class {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectTimeOfDay timeOfDay: DateComponents)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency)
}

class MoreOptionsViewModel {
    
    weak var delegate: MoreOptionsViewModelDelegate?
    let locationInputViewModel: LocationInputViewModel
    let dateInputViewModel: DateInputViewModel
    
    let numberOfSections = 0
    let numberOfRows = 0
    
    init(locationInputViewModel: LocationInputViewModel, dateInputViewModel: DateInputViewModel) {
        self.locationInputViewModel = locationInputViewModel
        self.dateInputViewModel = dateInputViewModel
        self.locationInputViewModel.delegate = self
        self.dateInputViewModel.delegate = self
    }
}

extension MoreOptionsViewModel: LocationInputDelegate {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool) {
        delegate?.locationInput(locationInputView, didFind: location, arriving: arriving)
    }
}

extension MoreOptionsViewModel: DateInputViewModelDelegate {

    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: DateComponents) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectTimeOfDay timeOfDay: DateComponents) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectTimeOfDay: timeOfDay)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectFrequency: frequency)
    }
}
