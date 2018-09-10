//
//  NewTaskViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 26/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol NewTaskViewModelOutputDelegate: class {
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTitle title: String?)
    func newTask(_ newTaskViewModel: NewTaskViewModel, didUpdateTags tags: [Tag]?)
}

class NewTaskViewModel {
    
    weak var outputDelegate: NewTaskViewModelOutputDelegate?
    private let taskModel: TaskModel
    private var task: Task?
    
    var taskTitleText: String? {
        didSet {
            outputDelegate?.newTask(self, didUpdateTitle: taskTitleText)
        }
    }
    
    
    init(task: Task?, taskModel: TaskModel) {
        self.taskModel = taskModel
        self.task = task
    }
    
    // MARK: - NSUserActivity
    fileprivate var userInfoEntries: [String : Any] {
        return [ "taskTitle" : taskTitleText ?? "" ]
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
