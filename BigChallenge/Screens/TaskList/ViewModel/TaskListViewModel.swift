//
//  TaskListViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol TaskListViewModelDelegate: class {
    
    // TODO follow proper delegate pattern
    func didTapAddButton()
    func didSelectTask(_ task: Task)
    
}

class TaskListViewModel {
    
    private let model: TaskModel
    
    var tasksObservable: Driver<[Task]> {
        return model.objectsObservable
    }
    
    weak var delegate: TaskListViewModelDelegate?
    
    init(model: TaskModel) {
        self.model = model
    }
    
    // TODO: delete this after rx
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
    
    func createCellViewModel(for task: Task) -> TaskCellViewModel {
        return TaskCellViewModel(task: task, model: model)
    }
    
    func didTapAddButton() {
        delegate?.didTapAddButton()
    }
    
    func removeTask(at indexPath: IndexPath) {
        if let task = taskForRowAt(indexPath: indexPath) {
            model.remove(object: task)
        }
    }
    
    func didSelectTask(at indexPath: IndexPath) {
        let task = model.task(at: indexPath.row)
        delegate?.didSelectTask(task)
    }
    
    // MARK: - Strings
    let viewTitle = String.taskListScreenTitle
    
}
