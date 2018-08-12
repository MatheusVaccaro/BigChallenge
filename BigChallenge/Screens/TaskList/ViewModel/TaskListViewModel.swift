//
//  TaskListViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
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
    
    var tasksToShow: [Task] {
        if showsCompletedTasks {
            return secondaryTasks + completedTasks
        } else { return secondaryTasks }
    }
    
    //    here i declare multiple arrays for completed and uncomplete tasks
    //    so that you dont need to filer the array everytime you complete a task
    private(set) var mainTasks: [Task]
    private(set) var secondaryTasks: [Task]
    private(set) var completedTasks: [Task]
    private(set) var selectedTags: [Tag]

    private let model: TaskModel
    private var disposeBag = DisposeBag()
    
    public init(model: TaskModel) {
        self.model = model
        self.mainTasks = []
        self.secondaryTasks = []
        self.completedTasks = []
        self.selectedTags = []
        
        self.taskCompleted = PublishSubject<Task>()
        self.shouldAddTask = BehaviorSubject<Bool>(value: false)
        self.tasksObservable = BehaviorSubject<([Task], [Task])>(value: (mainTasks, secondaryTasks))
        
        subscribeToCompletedTask()
        subscribeToModelUpdate()
    }
    
    /** filters the taskList with selected tags */
    func filterTasks(with tags: [Tag]) {
        self.selectedTags = tags
        mainTasks = []
        secondaryTasks = []
        completedTasks = []
        
        for task in model.tasks {
            appendTask(task)
        }
        
        guard !tags.isEmpty // if there are no selected tags, show recommended tasks
            else { tasksObservable.onNext((mainTasks, tasksToShow)); return }
        
        print(mainTasks.map {$0.title!})
        print(secondaryTasks.map {$0.title!})
        
        // filter tasks that dont contain any of the tags selected
        secondaryTasks =
            secondaryTasks.filter {
                // on main screen and task is recommended
                if selectedTags.isEmpty && model.recommendedTasks.contains($0) { return false }
                else if $0.tags!.allObjects.isEmpty { return true }
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
        return TaskCellViewModel(task: task, taskModel: model)
    }

    func shouldGoToAddTask() {
        self.shouldAddTask.onNext(true)
    }
    
    // MARK: Helpers
    /**
     verifies that task contains only one tag, which is the current selected tag
     */
    fileprivate func isMainTask(_ task: Task) -> Bool {
        if model.recommendedTasks.contains(task) && selectedTags.isEmpty { return true }
        
        let taskTags = (task.tags?.allObjects as! [Tag])
        
        return !selectedTags.isEmpty &&
            taskTags.count == selectedTags.count &&
            taskTags.map { $0.title! }.sorted() == selectedTags.map { $0.title! }.sorted() //TODO: improve this
    }
    
    /** appends a centain task to the appropriate array inside taskListViewModel */
    fileprivate func appendTask(_ task: Task) {
        if !task.isCompleted {
            if isMainTask(task) {
                mainTasks.append(task)
            } else {
                secondaryTasks.append(task)
            }
        } else {
            completedTasks.append(task)
        }
    }
    
    fileprivate func subscribeToModelUpdate() {
        model.didUpdateTasks.subscribe {
            guard $0.element != nil else { return }
            self.filterTasks(with: self.selectedTags)
            }.disposed(by: disposeBag)
    }
    
    fileprivate func subscribeToCompletedTask() {
        taskCompleted.subscribe { event in
            guard let task = event.element else { return }
            self.model.save(task) // model updated handles changing the arrays
        }.disposed(by: disposeBag)
    }
    
    // MARK: Strings
    let recommendedHeaderTitle = Strings.Task.ListScreen.recommendedHeaderTitle
    let section2HeaderTitle = Strings.Task.ListScreen.section2HeaderTitle
    
}
