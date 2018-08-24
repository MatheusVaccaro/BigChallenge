//
//  NewTaskViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 26/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol NewTaskViewModelDelegate: class {
    func didTapDeleteTaskButton()
    func didTapMoreOptionsButton()
    func willAddTag()
}

protocol NewTaskViewModelOutputDelegate: class {
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTitle title: String?)
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTags tags: [Tag]?)
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateNotes notes: String?)
}

class NewTaskViewModel: NewTaskViewModelProtocol {
    
    private let taskModel: TaskModel
    private var task: Task?
    var taskTitleText: String? {
        didSet {
            outputDelegate?.newTask(self, didUpdateTitle: taskTitleText)
        }
    }
    var selectedTags: [Tag] {
        didSet {
            outputDelegate?.newTask(self, didUpdateTags: selectedTags)
        }
    }
    var taskNotesText: String? {
        didSet {
            outputDelegate?.newTask(self, didUpdateNotes: taskNotesText)
        }
    }
    
    weak var outputDelegate: NewTaskViewModelOutputDelegate?
    weak var delegate: NewTaskViewModelDelegate?
    
    init(task: Task?, taskModel: TaskModel) {
        self.taskModel = taskModel
        self.task = task
        
        self.selectedTags = task == nil ? [] : task!.allTags
        self.taskNotesText = task?.notes ?? ""
    }
    
    func didTapDeleteTaskButton() {
        delegate?.didTapDeleteTaskButton()
        deleteTask()
    }
    
    private func deleteTask() {
        guard let task = task else { return }
        taskModel.delete(task)
    }
    
    func taskTitle() -> String? {
        return task?.title
    }
    
    func taskNotes() -> String? {
        return task?.notes
    }
    
    // MARK: - Strings
    func titleTextFieldPlaceholder() -> String {
        return Strings.Task.CreationScreen.taskTitlePlaceholder
    }
    
    // MARK: - NSUserActivity
    fileprivate var selectedTagIDs: [String] {
        return selectedTags.map { $0.id!.description }
    }
    
    fileprivate var userInfoEntries: [String : Any] {
        return [
            "taskTitle" : taskTitleText ?? "",
            "taskNotes" : taskNotesText ?? "",
            "selectedTags" : selectedTagIDs
        ] //location / date ??????????
    }
    
    func willAddTag() {
        delegate?.willAddTag()
    }
    
    lazy var userActivity: NSUserActivity = {
        let activity = NSUserActivity(activityType: "com.bigBeanie.finalChallenge.createTask")
        
        activity.userInfo = userInfoEntries
        
        activity.isEligibleForHandoff = true
        
        return activity
    }()
    
    func update(_ userActivity: NSUserActivity) {
        userActivity.addUserInfoEntries(from: userInfoEntries)
        userActivity.becomeCurrent()
    }
}
