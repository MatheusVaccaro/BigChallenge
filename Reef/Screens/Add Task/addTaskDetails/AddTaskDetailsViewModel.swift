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
                       didFind location: CLCircularRegion?,
                       named: String,
                       arriving: Bool)
    
    func taskDetailsViewModel(_ taskDetailsViewModel: AddTaskDetailsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectDate date: Date?)
    
    func taskDetailsViewModel(_ taskDetailsViewModel: AddTaskDetailsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectFrequency frequency: NotificationOptions.Frequency)
    
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String)
    
    func shouldPresent(viewModel: IconCellPresentable)
}

struct AddTaskDetailsCellKey {
    static let noteCell = 0
    static let locationCell = 1
    static let dateCell = 2
}

class AddTaskDetailsViewModel {
    
    weak var delegate: AddTaskDetailsDelegate?
    
    let notesInputViewModelType: NotesInputViewModel.Type
    var notesInputViewModel: NotesInputViewModel?
    
    let locationInputViewModelType: LocationInputViewModel.Type
    var locationInputViewModel: LocationInputViewModel?
    
    let dateInputViewModelType: DateInputViewModelProtocol.Type
    var dateInputViewModel: DateInputViewModelProtocol?
    
    private let _numberOfSections = 1
    private let _numberOfRows = 3
    
    private var cells: [IconCellPresentable?]
    private var placeholderCells: [IconCellPresentable]
    
    init(selectedTags: [Tag]) {
        locationInputViewModelType = LocationInputViewModel.self
        dateInputViewModelType = DateInputViewModel.self
        notesInputViewModelType = NotesInputViewModel.self

        cells = [notesInputViewModel, locationInputViewModel, dateInputViewModel]
        placeholderCells = [DefaultNotesInputIconCellPresentable(),
                            DefaultLocationInputIconCellPresentable(),
                            DefaultDateInputIconCellPresentable()]
    
//        locationInputViewModel.delegate = self
//        dateInputViewModel.delegate = self
//        notesInputViewModel.delegate = self
        
        //TODO: start cells with tag attributes
    }
    
    func edit(task: Task) {
        if task.notes != nil {
            instantiateCell(atRow: AddTaskDetailsCellKey.noteCell)
            notesInputViewModel?.edit(task)
        }
        
        if task.location != nil {
            instantiateCell(atRow: AddTaskDetailsCellKey.locationCell)
            locationInputViewModel?.edit(task)
        }
        
        if task.dueDate != nil {
            instantiateCell(atRow: AddTaskDetailsCellKey.dateCell)
            dateInputViewModel?.edit(task)
        }
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
        return cells[row] ?? placeholderCells[row]
    }
    
    func shouldPresentView(at row: Int) {
        if let cellViewModel = cells[row] ?? instantiateCell(atRow: row) {
            delegate?.shouldPresent(viewModel: cellViewModel)
        }
    }
    
    @discardableResult
    private func instantiateCell(atRow row: Int) -> IconCellPresentable? {
        let iconCellPresentable: IconCellPresentable?
        
        switch row {
        case AddTaskDetailsCellKey.noteCell:
            notesInputViewModel = notesInputViewModelType.init()
            notesInputViewModel?.delegate = self
            iconCellPresentable = notesInputViewModel
            
        case AddTaskDetailsCellKey.locationCell:
            locationInputViewModel = locationInputViewModelType.init()
            locationInputViewModel?.delegate = self
            iconCellPresentable = locationInputViewModel
            
        case AddTaskDetailsCellKey.dateCell:
            // Get the next hour (i.e. if it's 3:46, get 4:00)
            let now = Date.now()
            let nowHourComponent = Calendar.current.component(.hour, from: now)
            let nextHour = Calendar.current.date(bySettingHour: nowHourComponent + 1, minute: 0, second: 0, of: now)!
            
            let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: nextHour)
            
            dateInputViewModel = dateInputViewModelType.init(calendarDate: calendarDate, timeOfDay: timeOfDay,
                                                             frequency: .none, delegate: self)
            iconCellPresentable = dateInputViewModel
            
        default:
            iconCellPresentable = nil
        }
        
        cells[row] = iconCellPresentable
        
        return iconCellPresentable
    }
}

extension AddTaskDetailsViewModel: LocationInputDelegate {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion?,
                       named: String,
                       arriving: Bool) {
        delegate?.locationInput(locationInputViewModel, didFind: location, named: named, arriving: arriving)
    }
}

extension AddTaskDetailsViewModel: DateInputViewModelDelegate {

    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: Date?) {
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

private extension NotesInputViewModel {
    func edit(_ task: Task) {
        guard let taskNotes = task.notes else { return }
        notes = taskNotes
    }
}
