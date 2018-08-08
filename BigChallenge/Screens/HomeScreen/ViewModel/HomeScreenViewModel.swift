//
//  HomeScreenViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol HomeScreenViewModelDelegate: class {
    func willAddTask(selectedTags: [Tag])
    func wilEditTask()
    func willAddTag()
}

class HomeScreenViewModel {
    
    private(set) var selectedTags: [Tag]
    private(set) var taskModel: TaskModel
    private(set) var tagModel: TagModel
    
    init(taskModel: TaskModel, tagModel: TagModel, selectedTags: [Tag]) {
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
    }
    
    lazy var taskListViewModel: TaskListViewModel = {
        return TaskListViewModel(model: taskModel)
    }()
    
    lazy var tagCollectionViewModel: TagCollectionViewModel = {
        return TagCollectionViewModel(model: tagModel, filtering: true, selectedTags: selectedTags)
    }()
    
    var bigTitleText: String {
        if let tag = selectedTags.first {
            return tag.title!
        } else {
            return "Hello"
        }
    }
    
    fileprivate var userActivityTitle: String {
        var ans = ""
        guard !selectedTags.isEmpty else { return ans }
        
        var tags = (selectedTags.map { $0.title! })
        
        while tags.count > 1 {
            ans += "\(tags.removeFirst()), "
        }
        
        ans += tags.removeFirst()
        
        return ans
    }
    
    var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: "com.bigBeanie.finalChallenge.selectedTags")
        
        activity.userInfo =
            ["selectedTagIDs": selectedTags.map { $0.id!.description }]
        
        activity.keywords =
            Set<String>(selectedTags.map { $0.title! })
        
        activity.isEligibleForSearch = true
        activity.isEligibleForHandoff = true
        activity.isEligibleForPublicIndexing = true
        //TODO: uncomment when available
        //        if #available(iOS 12.0, *) {
        //            activity.isEligibleForPrediction = true
        //        }
        
        return activity
    }
    
    func updateSelectedTagsIfNeeded(_ tags: [Tag]?) {
        selectedTags = tags ?? []
        print("selected tags are: \(selectedTags.map { $0.title })")
    }
    
    func updateUserActivity(_ activity: NSUserActivity) {
        activity.addUserInfoEntries(from: ["selectedTagIDs" : selectedTags.map { $0.id!.description }])
        
        activity.keywords =
            Set<String>(selectedTags.map { $0.title! })
        
        activity.title = userActivityTitle
        
        activity.becomeCurrent()
    }
}
