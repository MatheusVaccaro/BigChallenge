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
import ReefKit
import ReefTableViewCell

public class TaskListViewModelImpl: TaskListViewModel {
    
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
    
    var isShowingRecommendedSection: Bool {
        return selectedTags.isEmpty && !model.recommended.isEmpty
    }
    
    var isShowingCard: Bool {
        return sections.first == selectedTags || isShowingRecommendedSection
    }
    
    private let model: TaskModel
    private var disposeBag = DisposeBag()
    
    required public init(model: TaskModel) {
        self.model = model
        self.tasks = []
        self.selectedTags = []
        self.relatedTags = []
        self.sections = []
        
        self.taskCompleted = PublishSubject<Task>()
        self.shouldAddTask = PublishSubject<Bool>()
        self.shouldEditTask = PublishSubject<Task>()
        
        self.tasksObservable = BehaviorSubject<[[Task]]>(value: tasks)
        
        subscribeToCompletedTask()
        subscribeToModelUpdate()
    }
    
    func task(for indexPath: IndexPath) -> Task {
        return tasks[indexPath.section][indexPath.row]
    }
    
    func tags(forHeadersInSection section: Int) -> [Tag] {
        let index = isShowingRecommendedSection
            ? section-1
            : section
        
        return sections[index]
            .filter { !selectedTags.contains($0) }
    }
    
    func hasHeaderInSection(_ section: Int) -> Bool {
        return !(section == 0 && !selectedTags.isEmpty && isCardSection(section))
    }
    
    func isCardSection(_ section: Int) -> Bool {
        return section == 0 && isShowingCard
    }
    
    /** filters the taskList with selected tags */
    func filterTasks(with selectedTags: [Tag], relatedTags: [Tag]) {
        //swiftlint:disable statement_postition
        self.selectedTags = selectedTags
        self.relatedTags = relatedTags
        self.tasks = []
        
        if selectedTags.isEmpty {
            tasks.append(model.recommended)
        }
        
        // remove completed and recommended (if on main screen)
        // remove tasks with none of the tags to filter by
        var flatTasks = model.tasks
            .filter { !$0.isCompleted && (selectedTags.isEmpty ? !model.recommended.contains($0) : true) }
            .filter { for tag in selectedTags where !$0.tags!.contains(tag) { return false }; return true }
            .filter {
                let privateTags = selectedTags.filter { $0.requiresAuthentication }
                // filter all privates if no private tag is selected
                guard !privateTags.isEmpty else { return !$0.isPrivate }
                
                // filter only private tasks of tags that arent selected
                for tag in privateTags { return tag.allTasks.contains($0) }
                return false
        }
        
        sections = relatedTags
            .powerSet
            .map { selectedTags + $0 }
        
        for tags in sections {
            let tasksInSection = flatTasks
                .filter { $0.allTags.count == tags.count && Set<Tag>($0.allTags) == Set<Tag>(tags) }
            
            flatTasks = flatTasks.filter { !tasksInSection.contains($0) } //remove from flattask to improve performance?
            
            if tasksInSection.isEmpty {
                if let index = sections.index(of: tags) {
                    sections.remove(at: index)
                }
            }
            tasks.append(tasksInSection)
        }
        
        tasks = tasks.filter { !$0.isEmpty }
        
        tasksObservable.onNext(tasks)
        //swiftlint:enable statement_postition
    }
    
    func taskCellViewModel(for task: Task) -> TaskCellViewModel {
        return TaskCellViewModel(task: task)
    }
    
    func shouldGoToAddTask() {
        self.shouldAddTask.onNext(true)
    }
    
    func shouldGoToEdit(_ task: Task) {
        self.shouldEditTask.onNext(task)
    }
    
    func completeTask(taskID: UUID) {
        guard let task = model.taskWith(id: taskID) else { return }
        task.isCompleted = true
        var taskAttributes: [TaskAttributes : Any] = [:]
        taskAttributes[.isCompleted] = true
        
        model.update(task, with: taskAttributes)
    }
    
    // MARK: Helpers
    /**
     verifies that task contains only one tag, which is the current selected tag
     */
    fileprivate func isMainTask(_ task: Task) -> Bool {
        if model.recommended.contains(task) && selectedTags.isEmpty { return true }
        
        return !selectedTags.isEmpty &&
            task.allTags.count == selectedTags.count &&
            Set<Tag>(task.allTags) == Set<Tag>(selectedTags)
    }
    
    fileprivate func subscribeToModelUpdate() {
        model.didUpdateTasks
            .subscribe(onNext: { _ in
                self.filterTasks(with: self.selectedTags, relatedTags: self.relatedTags)
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func subscribeToCompletedTask() {
        taskCompleted
            .subscribe(onNext: { task in
                self.model.save(task) // model updated handles changing the arrays
                Answers.logCustomEvent(withName: "completed task")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Strings
    let recommendedHeaderTitle = Strings.Task.ListScreen.recommendedHeaderTitle
    let section2HeaderTitle = Strings.Task.ListScreen.section2HeaderTitle
    
}
