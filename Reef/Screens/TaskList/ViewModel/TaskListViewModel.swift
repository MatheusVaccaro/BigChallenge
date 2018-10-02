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
import ReefKit

protocol TaskListDelegate: class {
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, shouldEdit task: Task)
    func didBecomeEmpty(_ bool: Bool)
}

protocol taskListViewModelUIDelegate: class {
    func taskListViewModelDidUpdate(_ taskListViewModel: TaskListViewModel)
}

public class TaskListViewModel {
    //    here i declare multiple arrays for completed and uncomplete tasks
    //    so that you dont need to filer the array everytime you complete a task
    private(set) var tasks: [(rows: [Task], header: String)]
    private(set) var selectedTags: [Tag]
    private(set) var relatedTags: [Tag]
    
    weak var delegate: TaskListDelegate?
    weak var UIDelegate: taskListViewModelUIDelegate?
    
    var isShowingRecommendedSection: Bool {
        return selectedTags.isEmpty
    }
    
    private let model: TaskModel
    
    required public init(model: TaskModel) {
        self.model = model
        self.tasks = []
        self.selectedTags = []
        self.relatedTags = []
        
        model.delegate = self
        
        print("+++ INIT TaskListViewModel")
    }
    
    deinit {
        print("--- DEINIT TaskListViewModel")
    }
    
    private var flatTasks: [Task] {
        return tasks.flatMap { $0.rows }
    }
    
    func task(for indexPath: IndexPath) -> Task {
        return tasks[indexPath.section].rows[indexPath.row]
    }
    
    func numberOfRows(in section: Int) -> Int {
        return tasks[section].rows.count
    }
    
    var numberOfSections: Int {
        return tasks.count
    }
    
    func title(forHeaderInSection section: Int) -> String {
        return tasks[section].header
    }
    
    /** filters the taskList with selected tags */
    func filterTasks(with selectedTags: [Tag], relatedTags: [Tag]) {
        //swiftlint:disable statement_postition
        self.selectedTags = selectedTags
        self.relatedTags = relatedTags
        self.tasks = []
        
        if selectedTags.isEmpty {
            tasks.append((rows: model.recommender.recentTasks, header: recentHeader))
            tasks.append((rows: model.recommender.localTasks, header: locationHeader))
            tasks.append((rows: model.recommender.nextTasks, header: nextHeader))
            tasks.append((rows: model.recommender.lateTasks, header: lateHeader))
        } else {
            //TODO: filter isCompleted in model
            let mainTasks = model.tasks.filter { !$0.isCompleted && isMainTask($0) }
            tasks.append((rows: mainTasks, header: ""))
        }
        
        //TODO: filter isCompleted in model
        let remainingTasks = model.tasks.filter { !$0.isCompleted && !flatTasks.contains($0) && !$0.isPrivate }
        tasks.append((rows: remainingTasks, header: otherHeader))
        
        tasks = tasks
            .filter { !$0.rows.isEmpty }
        
        UIDelegate?.taskListViewModelDidUpdate(self)
        delegate?.didBecomeEmpty(tasks.isEmpty)
    }
    
    func taskCellViewModel(for indexPath: IndexPath) -> TaskCellViewModel {
        let task = tasks[indexPath.section].rows[indexPath.row]
        let viewModel = TaskCellViewModel(task: task, taskModel: model)
        viewModel.delegate = self
        return viewModel
    }
    
    func shouldGoToEdit(_ task: Task) {
        delegate?.taskListViewModel(self, shouldEdit: task)
    }
    
    func delete(_ task: Task) {
        model.delete(task)
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
     verifies that task contains the same amount of tags, which are the selected tags
     */
    fileprivate func isMainTask(_ task: Task) -> Bool {
        return !selectedTags.isEmpty &&
            task.allTags.count == selectedTags.count &&
            Set<Tag>(task.allTags) == Set<Tag>(selectedTags)
    }
    
    // MARK: Strings
    let locationHeader = Strings.Task.ListScreen.locationHeader
    let lateHeader = Strings.Task.ListScreen.lateHeader
    let nextHeader = Strings.Task.ListScreen.upNextHeader
    let recentHeader = Strings.Task.ListScreen.recentHeader
    let otherHeader = Strings.Task.ListScreen.otherTasksHeader
}

extension TaskListViewModel: TaskCellViewModelDelegate {
    func shouldEdit(_ task: Task) {
        shouldGoToEdit(task)
    }
}

extension TaskListViewModel: TaskModelDelegate {
    func taskModel(_ taskModel: TaskModel, didInsert tasks: [Task]) {
        filterTasks(with: selectedTags, relatedTags: relatedTags)
    }
    
    func taskModel(_ taskModel: TaskModel, didDelete tasks: [Task]) {
        filterTasks(with: selectedTags, relatedTags: relatedTags)
    }
    
    func taskModel(_ taskModel: TaskModel, didUpdate tasks: [Task]) {
        filterTasks(with: selectedTags, relatedTags: relatedTags)
    }
}
