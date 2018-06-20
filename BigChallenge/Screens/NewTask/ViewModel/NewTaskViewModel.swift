//
//  NewTaskViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 26/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol NewTaskViewModelDelegate: class {
    
    func didTapCancelButton()
    func didTapDoneButton()
    func didTapDeleteTaskButton()
    
}

class NewTaskViewModel {
    
    private let model: TaskModel
    private var isEditing: Bool
    var task: Task
    
    weak var delegate: NewTaskViewModelDelegate?
    
    init(task: Task, isEditing: Bool, model: TaskModel) {
        self.task = task
        self.isEditing = isEditing
        self.model = model
    }
    
    var numberOfSections: Int {
        if isEditing {
            return 2
        } else {
            return 1
        }
    }
    
    var numberOfRowsInSection: Int {
        return 1
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapDoneButton() {
        delegate?.didTapDoneButton()
        if isEditing {
            updateTask()
        } else {
            addTask()
        }
    }
    
    func didTapDeleteTaskButton() {
        delegate?.didTapDeleteTaskButton()
        deleteTask()
    }
    
    private func deleteTask() {
        model.remove(object: task)
    }
    
    private func addTask() {
        model.save(object: task)
    }
    
    private func updateTask() {
        model.update(object: task)
    }
    
    // MARK: - Strings
    let titleTextFieldPlaceHolder = NSLocalizedString("Title", comment: "the placeholder title for a task")
    let doneItemTitle = NSLocalizedString("Done", comment: "done button to end editing task")
    let cancelItemTitle = NSLocalizedString("Cancel", comment: "cancel button to cancel editing task")
    
    var navigationItemTitle: String {
        var ans: String = ""
        if isEditing {
            ans = NSLocalizedString("Edit Task", comment: "button to edit task")
        } else {
            ans = NSLocalizedString("New Task", comment: "button to add new task")
        }
        return ans
    }
    
    var deleteButtonTitle: String {
        return NSLocalizedString("Delete Task", comment: "button used to delete a task")
    }
}
