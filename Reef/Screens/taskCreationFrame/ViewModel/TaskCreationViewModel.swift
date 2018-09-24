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
    func didCreateTask()
    func shouldEscape()
    func shouldPresentViewForLocationInput()
    func shouldPresentViewForDateInput()
    func shouldPresentViewForNotesInput()
    func shouldPresentMoreOptions()
    func shouldHideMoreOptions()
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
    
    func performEscape() {
        delegate?.shouldEscape()
    }
}

extension TaskCreationViewModel: NewTaskViewModelOutputDelegate {
    func shouldPresentMoreOptions() {
        delegate?.shouldPresentMoreOptions()
    }
    
    func shouldHideMoreOptions() {
        delegate?.shouldHideMoreOptions()
    }
    
    func didPressCreateTask() {
        if task == nil {
            model.save(model.createTask(with: attributes))
        } else {
            model.update(task!, with: attributes)
        }
        
        task = nil
        delegate?.didCreateTask()
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
    
    func moreOptionsViewModel(_ moreOptionsViewModel: MoreOptionsViewModel, dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: Date) {
        attributes[.dueDate] = date
    }
    
    func moreOptionsViewModel(_ moreOptionsViewModel: MoreOptionsViewModel, dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency) {
        //TODO: implement frequency
    }
    
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String) {
        attributes[.notes] = notes
    }
}
