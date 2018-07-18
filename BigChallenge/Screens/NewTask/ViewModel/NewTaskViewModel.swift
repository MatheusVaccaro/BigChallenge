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

protocol NewTaskViewModelProtocol {
    
    var taskTitleTextField: String? { get set }
    
    func numberOfSections() -> Int
    func numberOfRowsInSection() -> Int
    func didTapCancelButton()
    func didTapDoneButton()
    func didTapDeleteTaskButton()
    
    func taskTitle() -> String?
    func titleTextFieldPlaceholder() -> String
    func doneItemTitle() -> String
    func cancelItemTitle() -> String
    func navigationItemTitle() -> String
    func deleteButtonTitle() -> String
    
}

class NewTaskViewModel: NewTaskViewModelProtocol {
    
    private let model: TaskModel
    private var isEditing: Bool
    private var task: Task?
    var taskTitleTextField: String?
    
    weak var delegate: NewTaskViewModelDelegate?
    
    init(task: Task?, isEditing: Bool, model: TaskModel) {
        self.isEditing = isEditing
        self.model = model
        self.task = task
    }
    
    func numberOfSections() -> Int {
        if isEditing {
            return 2
        } else {
            return 1
        }
    }
    
    func numberOfRowsInSection() -> Int {
        return 1
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapDoneButton() {
        delegate?.didTapDoneButton()
        if isEditing {
            // TODO
        } else {
            createTask()
        }
    }
    
    func didTapDeleteTaskButton() {
        delegate?.didTapDeleteTaskButton()
        deleteTask()
    }
    
    private func deleteTask() {
        guard let task = task else { return }
        model.delete(object: task)
    }
    
    private func createTask() {
        guard let taskTitle = taskTitleTextField else { return }
        let task = model.createTask(with: taskTitle)
        self.task = task
        model.save(object: task)
    }
    
    func taskTitle() -> String? {
        return task?.title
    }
    
    // MARK: - Strings
    func titleTextFieldPlaceholder() -> String {
        return Strings.Task.CreationScreen.taskTitlePlaceholder
    }
    
    func doneItemTitle() -> String {
        return Strings.Task.CreationScreen.doneButton
    }
    
    func cancelItemTitle() -> String {
        return Strings.Task.CreationScreen.cancelButton
    }
    
    func navigationItemTitle() -> String {
        var ans: String = ""
        if isEditing {
            ans = Strings.Task.EditScreen.title
        } else {
            ans = Strings.Task.CreationScreen.title
        }
        return ans
    }
    
    func deleteButtonTitle() -> String {
        return Strings.Task.EditScreen.deleteButton
    }
}
