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

class NewTaskViewModel: NewTaskViewModelProtocol {
    
    private let taskModel: TaskModel
    private let tagModel: TagModel
    private var isEditing: Bool
    private var task: Task?
    var taskTitleTextField: String?
    
    weak var delegate: NewTaskViewModelDelegate?
    
    init(task: Task?, isEditing: Bool, taskModel: TaskModel, tagModel: TagModel) {
        self.isEditing = isEditing
        self.taskModel = taskModel
        self.tagModel = tagModel
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
        taskModel.delete(object: task)
    }
    
    private func createTask() {
        guard let taskTitle = taskTitleTextField else { return }
        let task = taskModel.createTask(with: taskTitle)
        self.task = task
        taskModel.save(object: task)
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
    
    func tagCollectionViewModel(tagModel: TagModel) -> TagCollectionViewModel {
        return TagCollectionViewModel(model: tagModel)
    }
}
