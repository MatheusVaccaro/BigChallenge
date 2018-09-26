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
    func presentMoreOptions()
    func hideMoreOptions()
}

class TaskCreationViewModel {
    
    weak var delegate: TaskCreationDelegate?
    weak var uiDelegate: TaskCreationUIDelegate?
    
    fileprivate var model: TaskModel
    fileprivate var attributes: [TaskAttributes : Any] = [:]
    fileprivate let moreOptionsViewModel: MoreOptionsViewModel
    fileprivate let newTaskViewModel: NewTaskViewModel
    fileprivate var task: Task?
    
    init(taskModel: TaskModel, moreOptionsViewModel: MoreOptionsViewModel, newTaskViewModel: NewTaskViewModel) {
        self.model = taskModel
        self.moreOptionsViewModel = moreOptionsViewModel
        self.newTaskViewModel = newTaskViewModel
        
        moreOptionsViewModel.delegate = self
        newTaskViewModel.outputDelegate = self
    }
    
    func edit(_ task: Task?) {
        if let task = task {
            self.task = task
            moreOptionsViewModel.edit(task: task)
            newTaskViewModel.edit(task)
        }
    }
    
    func set(tags: [Tag]) {
        attributes[.tags] = tags
    }

}

extension TaskCreationViewModel: NewTaskViewModelOutputDelegate {
    func shouldPresentMoreOptions() {
        uiDelegate?.presentMoreOptions()
    }
    
    func shouldHideMoreOptions() {
        uiDelegate?.hideMoreOptions()
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
    func shouldPresent(viewModel: IconCellPresentable) {
        delegate?.shouldPresent(viewModel: viewModel)
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
