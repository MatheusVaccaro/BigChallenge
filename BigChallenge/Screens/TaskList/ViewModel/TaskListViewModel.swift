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
    func didSelectTask(_ task: Task)
}

public class TaskListViewModel {
    
    public var tasksObservable: BehaviorSubject<[Task]>
    
    weak var delegate: TaskListViewModelDelegate?
    
    private let model: TaskModel
    private(set) var tasks: [Task]
    
    public init(model: TaskModel) {
        self.model = model
        self.tasks = model.tasks
        self.tasksObservable = BehaviorSubject<[Task]>(value: tasks)
        
        model.didUpdateTasks = {
            self.tasks = $0
            self.tasksObservable.onNext(self.tasks)
        }
    }
    
    func filterTasks(with tags: [Tag]) {
        //TODO: make this clear to read
        tasks = model.tasks

        guard !tags.isEmpty else {
            tasksObservable.onNext(tasks)
            return
        }
        
        tasks = //filter all tags in array (and)
            tasks.filter {
                for tag in tags where !$0.tags!.contains(tag) { return false }
                return true
        }
        
        tasksObservable.onNext(tasks)
    }
    
    func taskCellViewModel(for task: Task) -> TaskCellViewModel {
        return TaskCellViewModel(task: task)
    }
    
    func didSelectTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        delegate?.didSelectTask(task)
    }
}
