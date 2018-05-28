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
    
    private let persistence: Persistence
    private var isEditing: Bool
    var task: Task
    
    weak var delegate: NewTaskViewModelDelegate?
    
    init(task: Task, isEditing: Bool, persistence: Persistence) {
        self.task = task
        self.isEditing = isEditing
        self.persistence = persistence
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
    
    var navigationItemTitle: String {
        if isEditing {
            return "Edit Task"
        } else {
            return "New Task"
        }
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
        print("delete task")
    }
    
    private func addTask() {
        persistence.save(object: task)
    }
    
    private func updateTask() {
        print("update task")
    }
    
}
