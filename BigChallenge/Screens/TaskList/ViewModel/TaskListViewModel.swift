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

public class TaskListViewModel {
    
    var tasksObservable: BehaviorSubject<[Task]>
    var taskCompleted: PublishSubject<Task>
    var showsCompletedTasks: Bool = false {
        didSet {
            print((showsCompletedTasks ? "showing" : "not showing") + " completed tasks")
            tasksObservable.onNext(tasksToShow)
        }
    }
    
    var tasksToShow: [Task] {
        print(tasks.map {$0.title!})
        print(completedTasks.map {$0.title!})
        
        if showsCompletedTasks { return tasks + completedTasks }
        else { return tasks }
    }
    
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
            
            if let index = self.tasks.index(of: task) { // !task.iscompleted
                self.completedTasks.append(self.tasks.remove(at: index))
            } else if let index = self.completedTasks.index(of: task) {
                self.tasks.append(self.completedTasks.remove(at: index))
            }
            
            self.tasksObservable.onNext(self.tasksToShow)
        }.disposed(by: disposeBag)
        
        model.didUpdateTasks.subscribe{
            self.tasks = []
            self.completedTasks = []
            
            for task in $0.element! {
                if !task.isCompleted { self.tasks.append(task) }
                else { self.completedTasks.append(task) }
            }
            
            self.tasksObservable.onNext(self.tasksToShow)
        }.disposed(by: disposeBag)
    }
    
    func filterTasks(with tags: [Tag]) {
        tasks = []
        completedTasks = []
        
        for task in model.tasks {
            if !task.isCompleted { self.tasks.append(task) }
            else { self.completedTasks.append(task) }
        }
        
        guard !tags.isEmpty
            else { tasksObservable.onNext(tasksToShow); return }
        
        tasks =
            tasks.filter {
                for tag in tags where !$0.tags!.contains(tag) { return false }
                return true
        }
        
        completedTasks =
            completedTasks.filter {
                for tag in tags where !$0.tags!.contains(tag) { return false }
                return true
        }
        
        tasksObservable.onNext(tasksToShow)
    }
    
    func taskCellViewModel(for task: Task) -> TaskCellViewModel {
        return TaskCellViewModel(task: task)
    }
}
