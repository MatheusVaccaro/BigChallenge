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
    
    func moreOptionsViewModel(_ moreOptionsViewModel: MoreOptionsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectDate date: Date)
    
    func moreOptionsViewModel(_ moreOptionsViewModel: MoreOptionsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectFrequency frequency: NotificationOptions.Frequency)
    
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String)
    
    func shouldPresentViewForLocationInput()
    func shouldPresentViewForDateInput()
    func shouldPresentViewForNotesInput()
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
        notesInputViewModel.delegate = self
    }
    
    func edit(task: Task?) {
        locationInputViewModel.task = task
        dateInputViewModel.configure(with: task)
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
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion, arriving: Bool) {
        delegate?.locationInput(locationInputViewModel,
                                       didFind: location, arriving: arriving)
    }
}

extension MoreOptionsViewModel: DateInputViewModelDelegate {

    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: Date) {
        delegate?.moreOptionsViewModel(self, dateInputViewModel: dateInputViewModel,
                                       didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        delegate?.moreOptionsViewModel(self, dateInputViewModel: dateInputViewModel,
                                       didSelectFrequency: frequency)
    }
}

extension MoreOptionsViewModel: NotesInputViewModelDelegate {
    
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String) {
        delegate?.notesInput(notesInputViewModel, didUpdateNotes: notes)
    }
    
}
