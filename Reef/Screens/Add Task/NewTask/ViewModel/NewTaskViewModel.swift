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
    func shouldPresentDetails()
    func shouldHideDetails()
    func didPressCreateTask()
}

protocol NewTaskViewModelDelegate: class {
    func updateTextViewWith(text: String)
    func didUpdateColors()
}

class NewTaskViewModel {
    
    weak var outputDelegate: NewTaskViewModelOutputDelegate?
    
    init(selectedTags: [Tag]) {
        if !selectedTags.isEmpty {
            taskColors = selectedTags.first!.colors
        }
    }
    
    var taskTitleText: String? {
        didSet {
            outputDelegate?.newTask(self, didUpdateTitle: taskTitleText)
        }
    }
    
    var taskColors: [CGColor] = [UIColor.black.cgColor, UIColor.black.cgColor]
    
    func edit(_ task: Task?) {
        taskTitleText = task?.title
        
        if let colors = task?.allTags.first?.colors {
            taskColors = colors
        } else {
            taskColors = [UIColor.black.cgColor, UIColor.black.cgColor]
        }
    }
    
    func shouldPresentDetails(_ bool: Bool) {
        if bool {
            outputDelegate?.shouldPresentDetails()
        } else {
            outputDelegate?.shouldHideDetails()
        }
    }
    
    func shouldCreateTask() {
        outputDelegate?.didPressCreateTask()
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