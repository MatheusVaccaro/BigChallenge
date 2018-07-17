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
    
    var tasksObservable: BehaviorSubject<[Task]>
    var taskCompleted: PublishSubject<Task>
    weak var delegate: TaskListViewModelDelegate?
    
    private let model: TaskModel
    private(set) var tasks: [Task]
    private(set) var completedTasks: [Task]
    private var disposeBag = DisposeBag()
    
    public init(model: TaskModel) {
        self.model = model
        self.tasks = []
        self.completedTasks = []
        
        self.tasksObservable = BehaviorSubject<[Task]>(value: tasks)
        self.taskCompleted = PublishSubject<Task>()
        
        taskCompleted.subscribe { event in
            guard let task = event.element else {return}
            self.model.saveContext()
            
            if let index = self.tasks.firstIndex(of: task) { // !task.iscompleted
                self.completedTasks.append(self.tasks.remove(at: index))
            } else if let index = self.completedTasks.firstIndex(of: task) {
                self.tasks.append(self.completedTasks.remove(at: index))
            }
            
            self.tasksObservable.onNext(self.tasks)
        }.disposed(by: disposeBag)
        
        model.didUpdateTasks = {
            self.tasks = []
            self.completedTasks = []
            
            for task in $0 {
                if !task.isCompleted { self.tasks.append(task) }
                else { self.completedTasks.append(task) }
            }
            
            self.tasksObservable.onNext(self.tasks)
        }
    }
    
    func filterTasks(with tags: [Tag]) {
        //TODO: make this clear to read
        tasks = model.tasks.filter { !$0.isCompleted }

        guard !tags.isEmpty else {
            tasksObservable.onNext(tasks)
            return
        }
        
        tasks = //filter all tags in array (and)
            tasks.filter {
                for tag in tags where !$0.tags!.contains(tag) && !$0.isCompleted { return false }
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
