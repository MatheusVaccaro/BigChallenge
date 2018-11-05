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
                       named: String?,
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

private enum TaskDetailsCellType: Int {
    case notesCell
    case locationCell
    case dateCell
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
    
    private var cells: [TaskDetailsCellType: IconCellPresentable?]
    private var placeholderCells: [TaskDetailsCellType: IconCellPresentable]
    
    init(selectedTags: [Tag]) {
        locationInputViewModelType = LocationInputViewModel.self
        dateInputViewModelType = DateInputViewModel.self
        notesInputViewModelType = NotesInputViewModel.self

        // Cell view models are only instantiated when they are needed
        cells = [:]
        placeholderCells = [.notesCell: StaticIconCellPresentable.defaultNotesInputIconCellPresentable(),
                            .locationCell: StaticIconCellPresentable.defaultLocationInputIconCellPresentable(),
                            .dateCell: StaticIconCellPresentable.defaultDateInputIconCellPresentable()]
    }
    
    func edit(task: Task) {
        if task.notes != nil {
            if notesInputViewModel == nil {
                instantiateCell(ofType: .notesCell)
            }
            notesInputViewModel?.edit(task)
        }
        
        if task.location != nil {
            if locationInputViewModel == nil {
                instantiateCell(ofType: .locationCell)
            }
            locationInputViewModel?.edit(task)
        }
        
        if task.dueDate != nil {
            if dateInputViewModel == nil {
                qqqinstantiateCell(ofType: .dateCell)
            }
            dateInputViewModel?.edit(task)
        }
    }
    
    func set(_ tags: [Tag]) {
        if dateInputViewModel == nil {
            instantiateCell(ofType: .dateCell)
        }
        
        if locationInputViewModel == nil {
            instantiateCell(ofType: .locationCell)
        }
        
        dateInputViewModel!.add(tags)
        locationInputViewModel!.add(tags)
    }
}

private extension LocationInputViewModel {
    func edit(_ task: Task) {
        guard task.location != nil else { return }
        
        location = task.location
        isArriving = task.isArrivingLocation
        placeName = task.locationName!
    }
    
    func add(_ tags: [Tag]) {
        tagInfo = Array( tags
            .filter { $0.location != nil }
            .map { (text: $0.locationName!, colorIndex: Int($0.colorIndex)) }
            .prefix(2) )
    }
}

private extension DateInputViewModelProtocol {
    func edit(_ task: Task) {
        guard let dueDate = task.dueDate else { return }
        
        let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: dueDate)
        
        self.calendarDate.onNext(calendarDate)
        self.timeOfDay.onNext(timeOfDay)
    }
    
    mutating func add(_ tags: [Tag]) {
        tagInfo = Array( tags
            .filter { $0.dueDate != nil }
            .map { (text: $0.dueDate!.string(with: "dd MMM")!, colorIndex: Int($0.colorIndex)) }
            .prefix(2) )
    }
}

private extension NotesInputViewModel {
    func edit(_ task: Task) {
        guard let taskNotes = task.notes else { return }
        notes = taskNotes
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
        if let taskDetailsCellType = TaskDetailsCellType.init(rawValue: row),
            let cellViewModel = cells[taskDetailsCellType] ?? placeholderCells[taskDetailsCellType] {
            return cellViewModel
            
        } else {
            return placeholderCells.values.first!
        }
    }
    
    func shouldPresentView(at row: Int) {
        if let taskDetailsCellType = TaskDetailsCellType.init(rawValue: row),
            let cellViewModel = cells[taskDetailsCellType] ?? instantiateCell(ofType: taskDetailsCellType) {
            delegate?.shouldPresent(viewModel: cellViewModel)
            
            if taskDetailsCellType == .dateCell {
                let nextHour = Date.now().snappedToNextHour()
                let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: nextHour)
                dateInputViewModel?.selectCalendarDate(calendarDate)
                dateInputViewModel?.selectTimeOfDay(timeOfDay)
            }
        }
    }
    
    @discardableResult
    private func instantiateCell(ofType cellType: TaskDetailsCellType) -> IconCellPresentable? {
        let iconCellPresentable: IconCellPresentable?
        
        switch cellType {
        case .notesCell:
            notesInputViewModel = notesInputViewModelType.init()
            notesInputViewModel?.delegate = self
            iconCellPresentable = notesInputViewModel
            
        case .locationCell:
            locationInputViewModel = locationInputViewModelType.init()
            locationInputViewModel?.delegate = self
            iconCellPresentable = locationInputViewModel
            
        case .dateCell:
            dateInputViewModel = dateInputViewModelType.init(calendarDate: nil, timeOfDay: nil,
                                                             frequency: .none, delegate: self)
            iconCellPresentable = dateInputViewModel
        }
        
        cells[cellType] = iconCellPresentable
        
        return iconCellPresentable
    }
}

extension AddTaskDetailsViewModel: LocationInputDelegate {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion?, named: String?, arriving: Bool) {
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
