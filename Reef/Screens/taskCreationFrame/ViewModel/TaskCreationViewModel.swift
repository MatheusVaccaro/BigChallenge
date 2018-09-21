//
//  taskCreationViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 10/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit
import CoreLocation

protocol TaskCreationDelegate: class {
    func didTapAddTask()
    func didPanAddTask()
    func shouldPresentViewForLocationInput()
    func shouldPresentViewForDateInput()
    func shouldPresentViewForNotesInput()
}

class TaskCreationViewModel {
    
    weak var delegate: TaskCreationDelegate?
    
    fileprivate var model: TaskModel
    fileprivate var attributes: [TaskAttributes : Any] = [:]
    fileprivate let moreOptionsViewModel: MoreOptionsViewModel
    fileprivate let newTaskViewModel: NewTaskViewModel
    
    var task: Task? {
        didSet {
            moreOptionsViewModel.edit(task: task)
            newTaskViewModel.edit(task)
        }
    }
    
    init(taskModel: TaskModel, moreOptionsViewModel: MoreOptionsViewModel, newTaskViewModel: NewTaskViewModel) {
        self.model = taskModel
        self.moreOptionsViewModel = moreOptionsViewModel
        self.newTaskViewModel = newTaskViewModel
        
        moreOptionsViewModel.delegate = self
        newTaskViewModel.outputDelegate = self
    }
    
    func set(tags: [Tag]) {
        attributes[.tags] = tags
    }
}

extension TaskCreationViewModel: NewTaskViewModelOutputDelegate {
    func didPressCreateTask() {
        if task == nil {
            model.save(model.createTask(with: attributes))
        } else {
            model.update(task!, with: attributes)
        }
        
        task = nil
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTitle title: String?) {
        attributes[.title] = title
    }
}

extension TaskCreationViewModel: MoreOptionsViewModelDelegate {
    
    func shouldPresentViewForLocationInput() {
        delegate?.shouldPresentViewForLocationInput()
    }
    
    func shouldPresentViewForDateInput() {
        delegate?.shouldPresentViewForDateInput()
    }
    
    func shouldPresentViewForNotesInput() {
        delegate?.shouldPresentViewForNotesInput()
    }
    
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion, arriving: Bool) {
        
        attributes[.region] = location
        attributes[.isArriving] = arriving
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: DateComponents) {
        attributes[.dueDate] = Calendar.current.date(from: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        //TODO: implement frequency
    }
    
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String) {
        attributes[.notes] = notes
    }
}
