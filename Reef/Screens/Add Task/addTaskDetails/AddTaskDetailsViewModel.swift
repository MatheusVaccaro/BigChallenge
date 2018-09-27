//
//  AddTaskDetailsViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import ReefKit

protocol AddTaskDetailsDelegate: class {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion,
                       named: String,
                       arriving: Bool)
    
    func taskDetailsViewModel(_ taskDetailsViewModel: AddTaskDetailsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectDate date: Date)
    
    func taskDetailsViewModel(_ taskDetailsViewModel: AddTaskDetailsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectFrequency frequency: NotificationOptions.Frequency)
    
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String)
    
    func shouldPresent(viewModel: IconCellPresentable)
}

class AddTaskDetailsViewModel {
    
    init(selectedTags: [Tag]) {
        locationInputViewModel = LocationInputViewModel()
        dateInputViewModel = DateInputViewModel(calendarDate: nil, timeOfDay: nil)
        notesInputViewModel = NotesInputViewModel()

        locationInputViewModel.delegate = self
        dateInputViewModel.delegate = self
        notesInputViewModel.delegate = self
        
        //TODO: start cells with tag attributes
    }
    
    func edit(task: Task) {
        locationInputViewModel.edit(task)
        dateInputViewModel.edit(task)
    }
    
    weak var delegate: AddTaskDetailsDelegate?
    
    let locationInputViewModel: LocationInputViewModel
    let dateInputViewModel: DateInputViewModel
    let notesInputViewModel: NotesInputViewModel
    
    private let _numberOfSections = 1
    private let _numberOfRows = 3
    
    private var cells: [IconCellPresentable] {
        return [ notesInputViewModel, locationInputViewModel, dateInputViewModel ]
    }
}

extension AddTaskDetailsViewModel: AddDetailsProtocol {
    var numberOfSections: Int {
        return _numberOfSections
    }
    
    var numberOfRows: Int {
        return _numberOfRows
    }
    
    func viewModelForCell(at row: Int) -> IconCellPresentable {
        return cells[row]
    }
    
    func shouldPresentView(at row: Int) {
        delegate?.shouldPresent(viewModel: cells[row])
    }
}

extension AddTaskDetailsViewModel: LocationInputDelegate {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion,
                       named: String,
                       arriving: Bool) {
        delegate?.locationInput(locationInputViewModel, didFind: location, named: named, arriving: arriving)
    }
}

extension AddTaskDetailsViewModel: DateInputViewModelDelegate {

    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: Date) {
        delegate?.taskDetailsViewModel(self, dateInputViewModel: dateInputViewModel,
                                       didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        delegate?.taskDetailsViewModel(self, dateInputViewModel: dateInputViewModel,
                                       didSelectFrequency: frequency)
    }
}

extension AddTaskDetailsViewModel: NotesInputViewModelDelegate {
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String) {
        delegate?.notesInput(notesInputViewModel, didUpdateNotes: notes)
    }
}

private extension LocationInputViewModel {
    func edit(_ task: Task) {
        guard task.location != nil else { return }
        
        location = task.location
        isArriving = task.isArrivingLocation
        placeName = task.locationName!
    }
}

private extension DateInputViewModelProtocol {
    func edit(_ task: Task) {
        guard let dueDate = task.dueDate else { return }
        
        let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: dueDate)
        
        self.calendarDate.onNext(calendarDate)
        self.timeOfDay.onNext(timeOfDay)
    }
}
