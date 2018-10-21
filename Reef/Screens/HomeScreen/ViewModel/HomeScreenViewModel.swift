//
//  HomeScreenViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol HomeScreenViewModelDelegate: class {
    func homeScreenViewModelDidStartAddTask(_ homeScreenViewModel: HomeScreenViewModel)
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel, willEdit task: Task)
    
    func homeScreenViewModelWillImportFromReminders(_ homeScreenViewModel: HomeScreenViewModel)
    func homeScreenViewModelShouldShowImportFromRemindersOption(_ homeScreenViewModel: HomeScreenViewModel) -> Bool
}

class HomeScreenViewModel {
    
    private(set) var selectedTags: [Tag]
    private(set) var taskModel: TaskModel
    private(set) var tagModel: TagModel
    
    let emptyStateTitleText = Strings.HomeScreen.EmptyState.title
    let emptyStateSubtitleText = Strings.HomeScreen.EmptyState.subtitle
    let emptyStateOrText = Strings.HomeScreen.EmptyState.or
    let importFromRemindersText = Strings.HomeScreen.EmptyState.importFromReminders
    
    weak var delegate: HomeScreenViewModelDelegate?
    
    required init(taskModel: TaskModel,
                  tagModel: TagModel,
                  selectedTags: [Tag],
                  taskListViewModel: TaskListViewModel,
                  tagCollectionViewModel: TagCollectionViewModel) {
        
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
    }
        
    func startAddTask() {
        delegate?.homeScreenViewModelDidStartAddTask(self)
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
    
    lazy var userActivity: NSUserActivity = {
        let activity = NSUserActivity(activityType: "com.bigBeanie.finalChallenge.selectedTags")
        
        activity.userInfo =
            ["selectedTagIDs": selectedTags.map { $0.id!.description }]
        
        activity.isEligibleForHandoff = true
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
        }
        
        return activity
    }()
    
    func updateSelectedTagsIfNeeded(_ tags: [Tag]?) {
        selectedTags = tags ?? []
        print("selected tags are: \(selectedTags.map { $0.title })")
    }
    
    func updateUserActivity(_ activity: NSUserActivity) {
        guard !selectedTags.isEmpty else { return }
        activity.addUserInfoEntries(from: ["selectedTagIDs" : selectedTags.map { $0.id!.description }])
        
        activity.title = userActivityTitle
        
        activity.becomeCurrent()
    }
}
