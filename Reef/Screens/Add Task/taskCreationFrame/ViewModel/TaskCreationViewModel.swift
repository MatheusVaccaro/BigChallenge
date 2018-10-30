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
    func didCreateTask()
    func shouldPresent(viewModel: IconCellPresentable)
    func viewDidLoad()
    func dismiss()
}

protocol TaskCreationUIDelegate: class {
    func presentDetails()
    func hideDetails()
    func taskCreationViewModelDidChangeTaskInfo(_ taskCreationViewModel: TaskCreationViewModel)
}

class TaskCreationViewModel {
    
    weak var delegate: TaskCreationDelegate?
    weak var uiDelegate: TaskCreationUIDelegate?
    
    fileprivate var model: TaskModel
    fileprivate var taskInformation: TaskInformation = [:]
    fileprivate let taskDetails: AddTaskDetailsViewModel
    fileprivate let newTaskViewModel: NewTaskViewModel
    fileprivate var task: Task?
    
    var isEditing: Bool {
        return task != nil
    }
    
    init(taskModel: TaskModel, taskDetails: AddTaskDetailsViewModel, newTaskViewModel: NewTaskViewModel, selectedTags: [Tag]) {
        self.model = taskModel
        self.taskDetails = taskDetails
        self.newTaskViewModel = newTaskViewModel
        
        taskDetails.delegate = self
        newTaskViewModel.outputDelegate = self
        
        set(tags: selectedTags)
    }
    
    func edit(_ task: Task?) {
        if let task = task {
            self.task = task
            taskDetails.edit(task: task)
            newTaskViewModel.edit(task)
        }
    }
    
    func set(tags: [Tag]) {
        newTaskViewModel.set(tags)
        taskInformation[.tags] = tags
        taskDetails.set(tags)
        uiDelegate?.taskCreationViewModelDidChangeTaskInfo(self)
    }
}

extension TaskCreationViewModel: NewTaskViewModelOutputDelegate {
    func shouldPresentDetails() {
        uiDelegate?.presentDetails()
    }
    
    func shouldHideDetails() {
        uiDelegate?.hideDetails()
    }
    
    func didPressCreateTask() {
        if task == nil {
            model.save(model.createTask(with: taskInformation))
        } else {
            model.update(task!, with: taskInformation)
        }
        
        task = nil
        taskInformation = [:]
        
        delegate?.didCreateTask()
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTitle title: String?) {
        taskInformation[.title] = title
    }
}

extension TaskCreationViewModel: AddTaskDetailsDelegate {
    func shouldPresent(viewModel: IconCellPresentable) {
        delegate?.shouldPresent(viewModel: viewModel)
    }
    
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion?,
                       named: String?,
                       arriving: Bool) {
        
        taskInformation[.location] = location
        taskInformation[.isArrivingLocation] = arriving
        if let name = named {
            taskInformation[.locationName] = name
        }
    }
    
    func taskDetailsViewModel(_ taskDetailsViewModel: AddTaskDetailsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectDate date: Date?) {
        
        taskInformation[.dueDate] = date
    }
    
    func taskDetailsViewModel(_ taskDetailsViewModel: AddTaskDetailsViewModel,
                              dateInputViewModel: DateInputViewModelProtocol,
                              didSelectFrequency frequency: NotificationOptions.Frequency) {
        
        //TODO: implement frequency
    }
    
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String) {
        taskInformation[.notes] = notes
    }
}
