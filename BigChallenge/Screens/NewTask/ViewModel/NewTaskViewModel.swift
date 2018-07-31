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
    func didTapMoreOptionsButton()
}

class NewTaskViewModel: NewTaskViewModelProtocol {
    
    private let taskModel: TaskModel
    private var isEditing: Bool
    private var task: Task?
    var taskTitleText: String?
    var selectedTags: [Tag]
    var taskNotesText: String?
    var dueDate: Date?
    
    weak var delegate: NewTaskViewModelDelegate?
    
    init(task: Task?, isEditing: Bool, taskModel: TaskModel) {
        self.isEditing = isEditing
        self.taskModel = taskModel
        self.task = task
        self.selectedTags = []
    }
    
    func numberOfSections() -> Int {
        if isEditing {
            return 2
        } else {
            return 1
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
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
    
    func didTapMoreOptionsButton() {
        delegate?.didTapMoreOptionsButton()
    }
    
    private func deleteTask() {
        guard let task = task else { return }
        taskModel.delete(task)
    }
    
    private func createTask() {
        guard let taskTitle = taskTitleText else { return }
        guard let taskNotes = taskNotesText else { return }
        let attributes: [TaskModel.Attributes : Any] = [
            .title : taskTitle,
            .notes : taskNotes
        ]
        let task = taskModel.createTask(with: attributes)
        self.task = task
        selectedTags.forEach { tag in
            self.task?.addToTags(tag)
        }
        taskModel.save(task)
    }
    
    func taskTitle() -> String? {
        return task?.title
    }
    
    func taskNotes() -> String? {
        return task?.notes
    }
    
    // MARK: - Strings
    func titleTextFieldPlaceholder() -> String {
        return Strings.Task.CreationScreen.taskTitlePlaceholder
    }
}
