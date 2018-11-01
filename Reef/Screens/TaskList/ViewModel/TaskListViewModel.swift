//
//  TaskListViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import Crashlytics
import ReefKit

protocol TaskListDelegate: class {
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, shouldEdit task: Task)
    func didBecomeEmpty(_ bool: Bool)
}

protocol taskListViewModelUIDelegate: class {
    func taskListViewModelDidUpdate(_ taskListViewModel: TaskListViewModel)
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didUpdateAt indexPaths: [IndexPath])
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didInsertAt indexPaths: [IndexPath])
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didDeleteRowsAt indexPaths: [IndexPath])
    func taskListViewModel(_ taskListViewModel: TaskListViewModel, didDeleteSection section: Int)
}

public class TaskListViewModel {
    //    here i declare multiple arrays for completed and uncomplete tasks
    //    so that you dont need to filer the array everytime you complete a task
    private(set) var taskListData: [(rows: [Task], header: String)]
    private(set) var selectedTags: [Tag]
    private(set) var relatedTags: [Tag]
    
    weak var delegate: TaskListDelegate?
    
    weak var UIDelegate: taskListViewModelUIDelegate?
    
    var isShowingRecommendedSection: Bool {
        return selectedTags.isEmpty
    }
    
    private let model: TaskModel
    
    required public init(model: TaskModel, selectedTags: [Tag] = []) {
        self.model = model
        self.taskListData = []
        self.selectedTags = selectedTags
        self.relatedTags = []
        
        model.delegate = self
        
        print("+++ INIT TaskListViewModel")
        
        filterTasks(with: selectedTags, relatedTags: relatedTags)
    }
    
    deinit {
        print("--- DEINIT TaskListViewModel")
    }
    
    private var flatTasks: [Task] {
        return taskListData.flatMap { $0.rows }
    }
    
    func task(for indexPath: IndexPath) -> Task {
        return taskListData[indexPath.section].rows[indexPath.row]
    }
    
    func numberOfRows(in section: Int) -> Int {
        if isCompleted(section), isCompleteSectionCollapsed {
            return 0
        }
        
        return taskListData[section].rows.count
    }
    
    var numberOfSections: Int {
        return taskListData.count
    }
    
    var isCompleteSectionCollapsed: Bool = true
    
    var hasCompletedTasks: Bool {
        return taskListData.last?.rows.first?.isCompleted ?? false
    }
    
    func title(forHeaderInSection section: Int) -> String {
        return taskListData[section].header
    }
    
    func isCompleted(_ section: Int) -> Bool {
        guard hasCompletedTasks else { return false }
        return taskListData.count-1 == section
    }
    
    /** filters the taskList with selected tags */
    func filterTasks(with selectedTags: [Tag], relatedTags: [Tag]) {
        //swiftlint:disable statement_postition
        self.selectedTags = selectedTags
        self.relatedTags = relatedTags
        self.taskListData = []
        
        if selectedTags.isEmpty { //RECOMMENDED
            taskListData.append((rows: model.recommender.recentTasks, header: recentHeader))
            taskListData.append((rows: model.recommender.localTasks, header: locationHeader))
            taskListData.append((rows: model.recommender.nextTasks, header: nextHeader))
            taskListData.append((rows: model.recommender.lateTasks, header: lateHeader))
        } else { //TASKS FROM TAGS
            let mainTasks = model.tasks.filter { !$0.isCompleted && isMainTask($0) }
            taskListData.append((rows: mainTasks, header: ""))
        }
        
        //OTHER TASKS
        var remainingTasks = model.tasks
            .filter { $0.hasOneOf(selectedTags) && !flatTasks.contains($0) }
        
        //filter private
        if !selectedTags.contains { $0.requiresAuthentication } {
            remainingTasks = remainingTasks.filter { !$0.isPrivate }
        }
        
        //completed
        let completedTasks = remainingTasks
            .filter { $0.isCompleted }
        
        // remove completed
        remainingTasks.removeAll { $0.isCompleted }
        
        taskListData.append((rows: remainingTasks, header: otherHeader))
        taskListData.append((rows: completedTasks, header: completeHeader))
        
        taskListData = taskListData
            .filter { !$0.rows.isEmpty }
        
        UIDelegate?.taskListViewModelDidUpdate(self)
        delegate?.didBecomeEmpty(taskListData.isEmpty)
    }
    
    func taskCellViewModel(for indexPath: IndexPath) -> TaskCellViewModel {
        let task = taskListData[indexPath.section].rows[indexPath.row]
        let viewModel = TaskCellViewModel(task: task, taskModel: model)
        viewModel.delegate = self
        return viewModel
    }
    
    func shouldGoToEdit(_ task: Task) {
        delegate?.taskListViewModel(self, shouldEdit: task)
    }
    
    func completeTask(taskID: UUID) {
        guard let task = model.taskWith(id: taskID) else { return }
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
    let completeHeader = Strings.Task.ListScreen.completedHeader
    
    var showHideHeader: String {
        return isCompleteSectionCollapsed
                ? Strings.General.show
                : Strings.General.hide
    }
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
    
    func delete(taskAt indexPath: IndexPath) {
        let task = taskListData[indexPath.section].rows[indexPath.row]
        model.delete(task)
    }
    
    func taskModel(_ taskModel: TaskModel, didDelete tasks: [Task]) {
        guard !taskListData.isEmpty else { return }
        
        for task in tasks {
            var section = 0
            while section < taskListData.count {
                if let index = taskListData[section].rows.index(of: task) {
                    if taskListData[section].rows.count == 1 {
                        taskListData.remove(at: section)
                        UIDelegate?.taskListViewModel(self,
                                                      didDeleteSection: section)
                    } else {
                        taskListData[section].rows.remove(at: index)
                        UIDelegate?.taskListViewModel(self,
                                                      didDeleteRowsAt: [IndexPath(row: index,
                                                                                  section: section)])
                    }
                }
                section += 1
            }
        }
        
        delegate?.didBecomeEmpty(taskListData.isEmpty)
    }
    
    func toggleComplete(taskAt indexPath: IndexPath) {
        let task = taskListData[indexPath.section].rows[indexPath.row]
        let taskAttributes: [TaskAttributes : Any] = [.isCompleted:!task.isCompleted]
        
        model.update(task, with: taskAttributes)
    }
    
    func taskModel(_ taskModel: TaskModel, didUpdate tasks: [Task]) {
        guard !taskListData.isEmpty else { return }
        
        for task in tasks {
            var section = 0
            while section < taskListData.count {
                if let row = taskListData[section].rows.index(of: task) {
                    if taskListData[section].rows.count == 1 {
                        filterTasks(with: selectedTags, relatedTags: relatedTags)
                        UIDelegate?.taskListViewModelDidUpdate(self)
                    } else {
                        UIDelegate?.taskListViewModel(self, didUpdateAt: [IndexPath(row: row, section: section)])
                    }
                }
                section += 1
            }
        }
    }
}

private extension Task {
    func hasOneOf(_ tags: [Tag]) -> Bool {
        guard !tags.isEmpty else { return true }
        
        for tag in tags {
            if allTags.contains(tag) { return true }
        }
        return false
    }
}
