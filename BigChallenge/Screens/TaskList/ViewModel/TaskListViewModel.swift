//
//  TaskListViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol TaskListViewModelDelegate: class {
    
    func didTapAddButton()
    func didSelectTask(_ task: Task)
    
}

class TaskListViewModel {
    
    private let model: TaskModel
    
    weak var delegate: TaskListViewModelDelegate?
    
    init(_ model: TaskModel) {
        self.model = model
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRowsInSection: Int {
        return model.count
    }
    
    func taskForRowAt(indexPath: IndexPath) -> Task? {
        let row = indexPath.row
        if row <= model.count {
            return model.task(at: row)
        } else {
            return nil
        }
    }
    
    // TODO: delete this after rx
    func createCellViewModelForTask(indexPath: IndexPath) -> TaskCellViewModel {
        return TaskCellViewModel(task: model.task(at: indexPath.row), model: model)
    }
    
    func didTapAddButton() {
        delegate?.didTapAddButton()
    }
    
    func removeTask(at indexPath: IndexPath) {
        model.remove(at: indexPath.row)
    }
    
    func didSelectTask(at indexPath: IndexPath) {
        let task = model.task(at: indexPath.row)
        delegate?.didSelectTask(task)
    }
    
    // MARK: - Strings
    let viewTitle = NSLocalizedString("Tasks", comment: "title of the tasklist tableView")
    
}
