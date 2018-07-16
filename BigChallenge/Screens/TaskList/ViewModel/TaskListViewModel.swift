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
    private var tasks: [Task]
    
    public init(model: TaskModel) {
        self.model = model
        self.tasks = model.tasks
        self.tasksObservable = BehaviorSubject<[Task]>(value: tasks)
        
        model.didUpdateTasks = {
            self.tasks = $0
            self.tasksObservable.onNext(self.tasks)
        }
    }
    
    func filterTasks(with tags: [Tag]? = nil) {
        //TODO: Do
        
        if let tags = tags {
            tasks =
                tasks.filter { $0.tags!.contains(where: { (tag) -> Bool in
                    if let tag = tag as? Tag {
                        for tagToFilterBy in tags {
//                            if tag == tagToFilterBy {
//                                return true
//                            }
                            //TODO: Filter
                            if tag.title == "Reminders" {
                                return true
                            }
                        }
                    }
                    return false
                }) }
        } else {
            tasks = model.tasks //TODO: recommended tags
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
