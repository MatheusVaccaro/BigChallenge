//
//  CreationFrameView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 02/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

protocol CreationFrameViewModelDelegate: class {
    func didTapCancelButton()
    func didTapSaveButton()
}

class CreationFrameViewModel {
    
    fileprivate var taskModel: TaskModel
    
    fileprivate var taskTitle: String!
    fileprivate var taskTags: [Tag] = []
    fileprivate var taskNotes: String = ""
    fileprivate var taskRegion: CLCircularRegion?
    fileprivate var taskArriving: Bool = false
    fileprivate var taskDueDate: Date?
    
    weak var delegate: CreationFrameViewModelDelegate?
    
    init(mainInfoViewModel: NewTaskViewModel,
         detailViewModel: MoreOptionsViewModel,
         taskModel: TaskModel) {
        self.taskModel = taskModel
        
        mainInfoViewModel.outputDelegate = self
        detailViewModel.delegate = self
    }
    
    var canCreateTask: Bool {
        guard taskTitle != nil else { return false }
        return true
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapSaveButton() {
        createTaskIfPossible()
        delegate?.didTapSaveButton()
    }
    
    private func createTaskIfPossible() {
        var attributes: [TaskModel.Attributes : Any] = [
            .title : taskTitle,
            .tags : taskTags,
            .notes : taskNotes,
            .arriving : taskArriving
        ]
        
        if let date = taskDueDate {
            attributes[.dueDate] = date
        }
        if let region = taskRegion {
            attributes[.region] = region
        }
        
        let task = taskModel.createTask(with: attributes)
        taskModel.save(task)
    }
}

extension CreationFrameViewModel: NewTaskViewModelOutputDelegate {
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTitle title: String?) {
        taskTitle = title ?? ""
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTags tags: [Tag]?) {
        taskTags = tags ?? []
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateDueDate dueDate: Date?) {
        taskDueDate = dueDate
    }
    
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateNotes notes: String?) {
        taskNotes = notes ?? ""
    }
}

extension CreationFrameViewModel: MoreOptionsViewModelDelegate {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool) {
        taskRegion = location
        taskArriving = arriving
    }
}
