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
    
    private let persistence: Persistence
    private var tasks: [Task] = []
    
    weak var delegate: TaskListViewModelDelegate?
    
    init(persistence: Persistence) {
        self.persistence = persistence
        
        tasks = persistence.fetchAll(Task.self)
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRowsInSection: Int {
        return tasks.count
    }
    
    func taskForRowAt(indexPath: IndexPath) -> Task? {
        let row = indexPath.row
        if row <= tasks.count {
            return tasks[row]
        } else {
            return nil
        }
    }
    
    func didTapAddButton() {
        delegate?.didTapAddButton()
    }
    
    func removeTask(at indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
    }
    
    func didSelectTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        delegate?.didSelectTask(task)
    }
    
}
