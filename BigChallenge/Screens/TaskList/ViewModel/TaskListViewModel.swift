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
    func didTapAddButton()
    func didSelectTask(_ task: Task)
}

public class TaskListViewModel {
    
    public var tasksObservable: BehaviorSubject<[Task]>
    private let model: TaskModel
    private var tasks: [Task]
    weak var delegate: TaskListViewModelDelegate?
    
    public init(model: TaskModel) {
        self.model = model
        tasks = model.tasks
        tasksObservable = BehaviorSubject<[Task]>(value: tasks)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangePersistence(_:)),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didChangePersistence(_ notification: Notification) {
        let dict = notification.userInfo!
        if let objects = dict["inserted"] as? NSSet {
            for task in objects where task is Task {
                tasks.append(task as! Task)
            }
            tasksObservable.onNext( tasks )
        }
    }
    
    func createCellViewModel(for task: Task) -> TaskCellViewModel {
        return TaskCellViewModel(task: task, model: model)
    }
    
    func didTapAddButton() {
        // TODO remove
//        let local = LocalPersistence()
//        local.clearDatabase()
        delegate?.didTapAddButton()
    }
    
    func didSelectTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        delegate?.didSelectTask(task)
    }
    
    // MARK: - Strings
    let viewTitle = String.taskListScreenTitle
    
}
