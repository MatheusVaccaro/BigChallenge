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
    
    var tasksObservable: BehaviorSubject<([Task], [Task])>
    var taskCompleted: PublishSubject<Task>
    var shouldAddTask: BehaviorSubject<Bool>
    
    var showsCompletedTasks: Bool = false {
        didSet {
            print((showsCompletedTasks ? "showing" : "not showing") + " completed tasks")
            tasksObservable.onNext((mainTasks, tasksToShow))
        }
    }
    
    var tasksToShow: [Task] { //TODO: TEMPORARY: CHANGE THIS WHEN LIST HAS TWO SECTIONS
        if showsCompletedTasks { return secondaryTasks + completedTasks }
        else { return secondaryTasks }
    }
    
    private(set) var mainTasks: [Task]
    private(set) var secondaryTasks: [Task]
//    here i declare multiple arrays for completed and uncomplete tasks
//    so that you dont need to filer the array everytime you complete a task
    private(set) var completedTasks: [Task]
    fileprivate var tagsBeingUsed: [Tag]?

    private let model: TaskModel
    private var disposeBag = DisposeBag()
    
    public init(model: TaskModel) {
        self.model = model
        self.mainTasks = []
        self.secondaryTasks = []
        self.completedTasks = []
        
        self.taskCompleted = PublishSubject<Task>()
        self.shouldAddTask = BehaviorSubject<Bool>(value: false)
        self.tasksObservable = BehaviorSubject<([Task], [Task])>(value: (mainTasks, secondaryTasks))
        
        subscribeToCompletedTask()
        subscribeToModelUpdate()
    }
    
    /** filters the taskList with selected tags */
    func filterTasks(with tags: [Tag]) {
        self.tagsBeingUsed = tags
        
        mainTasks = []
        secondaryTasks = []
        completedTasks = []
        
        for task in model.tasks {
            appendTask(task)
        }
        
        guard !tags.isEmpty
            else { tasksObservable.onNext((mainTasks, tasksToShow)); return }
        
        // filter tasks that dont containt any of the tags selected
        secondaryTasks =
            secondaryTasks.filter {
                for tag in tags where !$0.tags!.contains(tag) { return false }
                return true
        }
        
        completedTasks =
            completedTasks.filter {
                for tag in tags where !$0.tags!.contains(tag) { return false }
                return true
        }
        
        tasksObservable.onNext((mainTasks, tasksToShow))
    }
    
    func taskCellViewModel(for task: Task) -> TaskCellViewModel {
        return TaskCellViewModel(task: task)
    }
    
    func shouldGoToAddTask() {
        self.shouldAddTask.onNext(true)
    }
    
    //MARK: Helpers
    
    /**
     verifies that task contains only one tag, which is the current selected tag
     */
    fileprivate func isMainTask(_ task: Task) -> Bool {
        let tags = (task.tags?.allObjects as! [Tag])
        
        return tags == tagsBeingUsed
    }
    
    /** appends a centain task to the appropriate array inside taskListViewModel */
    fileprivate func appendTask(_ task: Task) {
        if !task.isCompleted {
            if isMainTask(task) { // this whould be better as a one-line if ;-;
                mainTasks.append(task)
            } else {
                secondaryTasks.append(task)
            }
        } else {
            completedTasks.append(task)
        }
    }
    
    fileprivate func subscribeToModelUpdate() {
        model.didUpdateTasks.subscribe{
            self.mainTasks = []
            self.secondaryTasks = []
            self.completedTasks = []
            
            for task in $0.element! {
                self.appendTask(task)
            }
            
            self.tasksObservable.onNext((self.mainTasks, self.tasksToShow))
            }.disposed(by: disposeBag)
    }
    
    fileprivate func subscribeToCompletedTask() {
        taskCompleted.subscribe { event in
            
            guard let task = event.element else {return}
            self.model.saveContext() // saving the context updated the view, also
            
            self.tasksObservable.onNext((self.mainTasks, self.tasksToShow))
            }.disposed(by: disposeBag)
    }
}
