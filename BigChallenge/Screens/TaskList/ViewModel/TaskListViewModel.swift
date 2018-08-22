//
//  TaskListViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import Crashlytics
import UIKit
import RxCocoa
import RxSwift

public class TaskListViewModel {
    
    var tasksObservable: BehaviorSubject<[[Task]]>
    var taskCompleted: PublishSubject<Task>
    var shouldAddTask: PublishSubject<Bool>
    var shouldEditTask: PublishSubject<Task>
    
    //    here i declare multiple arrays for completed and uncomplete tasks
    //    so that you dont need to filer the array everytime you complete a task
    private(set) var sections: [[Tag]]
    private(set) var tasks: [[Task]]
    private(set) var selectedTags: [Tag]
    private(set) var relatedTags: [Tag]

    private var recommender: Recommender
    private let model: TaskModel
    private var disposeBag = DisposeBag()
    
    public init(model: TaskModel) {
        self.model = model
        self.tasks = []
        self.selectedTags = []
        self.relatedTags = []
        self.sections = []
        
        self.taskCompleted = PublishSubject<Task>()
        self.shouldAddTask = PublishSubject<Bool>()
        self.shouldEditTask = PublishSubject<Task>()
        
        self.tasksObservable = BehaviorSubject<[[Task]]>(value: tasks)
        self.recommender = Recommender(model: model)
        
        subscribeToCompletedTask()
        subscribeToModelUpdate()
    }
    
    var isShowingCard: Bool {
        return sections.first == selectedTags ||
            (selectedTags.isEmpty && !recommender.recommendedTasks.isEmpty)
    }
    
    func name(forHeaderIn section: Int) -> String {
        var ans = ""
        let index = isShowingCard && selectedTags.isEmpty ? section-1 : section // diff recommended section
        
        ans += sections[index].map { $0.title! }.description
        
        return ans
    }
    
    func hasHeaderIn(_ section: Int) -> Bool {
        return !(section == 0 && !selectedTags.isEmpty && isCard(section))
    }
    
    func isCard(_ section: Int) -> Bool {
        return section == 0 && isShowingCard
    }
    
    /** filters the taskList with selected tags */
    func filterTasks(with selectedTags: [Tag], relatedTags: [Tag]) {
        //swiftlint:disable statement_postition
        self.selectedTags = selectedTags
        self.relatedTags = relatedTags
        self.tasks = []
        
        if selectedTags.isEmpty {
            tasks.append(recommender.recommendedTasks)
        }
        
        // remove completed and recommended (if on main screen)
        // remove tasks with none of the tags to filter by
        var flatTasks = model.tasks
            .filter { !$0.isCompleted && (selectedTags.isEmpty ? !recommender.recommendedTasks.contains($0) : true) }
            .filter { for tag in selectedTags where !$0.tags!.contains(tag) { return false }; return true }
        
        sections = relatedTags.powerSet
            .map { selectedTags + $0 }
        
        for tags in sections {
            let tasksInSection = flatTasks
                .filter { $0.allTags.count == tags.count &&
                          $0.tags! == NSSet(array: tags) }
            
            flatTasks = flatTasks.filter { !tasksInSection.contains($0) } // ??????????
            
            if tasksInSection.isEmpty { sections.remove(at: sections.index(of: tags)! ) }
            tasks.append(tasksInSection)
        }
        
        tasks = tasks
            .filter { !$0.isEmpty }
        
        tasksObservable.onNext(tasks)
        //swiftlint:enable statement_postition
    }
    
    func taskCellViewModel(for task: Task) -> TaskCellViewModel {
        return TaskCellViewModel(task: task, taskModel: model)
    }

    func shouldGoToAddTask() {
        self.shouldAddTask.onNext(true)
    }
    
    func shouldGoToEdit(_ task: Task) {
        self.shouldEditTask.onNext(task)
    }
    
    // MARK: Helpers
    /**
     verifies that task contains only one tag, which is the current selected tag
     */
    fileprivate func isMainTask(_ task: Task) -> Bool {
        if recommender.recommendedTasks.contains(task) && selectedTags.isEmpty { return true }
        
        return !selectedTags.isEmpty &&
            task.allTags.count == selectedTags.count &&
            task.allTags.map { $0.title! }.sorted() == selectedTags.map { $0.title! }.sorted()
        //TODO: improve this
    }
    
    fileprivate func subscribeToModelUpdate() {
        model.didUpdateTasks.subscribe {
            guard $0.element != nil else { return }
            self.filterTasks(with: self.selectedTags, relatedTags: self.relatedTags)
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
