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
    
    func shouldPresentViewForLocationInput()
    func shouldPresentViewForDateInput()
}

protocol MoreOptionsViewModelUIDelegate: class {
    func shouldUpdateTableView()
}

class MoreOptionsViewModel {
    
    init() {
        locationInputViewModel = LocationInputViewModel()
        dateInputViewModel = DateInputViewModel()
        notesInputViewModel = NotesInputViewModel()

        locationInputViewModel.delegate = self
        dateInputViewModel.delegate = self
    }
    
    func edit(task: Task?) {
        locationInputViewModel.task = task
        dateInputViewModel.task = task
        UIDelegate.shouldUpdateTableView()
    }
    
    weak var delegate: MoreOptionsViewModelDelegate?
    weak var UIDelegate: MoreOptionsViewModelUIDelegate!
    
    let locationInputViewModel: LocationInputViewModel
    let dateInputViewModel: DateInputViewModel
    let notesInputViewModel: NotesInputViewModel
    
    let numberOfSections = 1
    let numberOfRows = 3
}

extension MoreOptionsViewModel: LocationInputDelegate {    
    func locationInput(_ locationInputViewModel: LocationInputViewModel, didFind location: CLCircularRegion, arriving: Bool) {
        delegate?.locationInput(locationInputViewModel, didFind: location, arriving: arriving)
    }
}

extension MoreOptionsViewModel: DateInputViewModelDelegate {

    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: DateComponents) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectFrequency: frequency)
    }
}
