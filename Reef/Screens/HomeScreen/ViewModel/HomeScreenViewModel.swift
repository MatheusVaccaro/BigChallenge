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
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             willAddTaskWithSelectedTags selectedTags: [Tag])
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel, willEdit task: Task)
    
    func homeScreenViewModelWillImportFromReminders(_ homeScreenViewModel: HomeScreenViewModel)
    
    func homeScreenViewModelShouldShowImportFromRemindersOption(_ homeScreenViewModel: HomeScreenViewModel) -> Bool
    
    func homeScreenViewModelWillAddTag(_ homeScreenViewModel: HomeScreenViewModel)
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             didInstantiate taskListViewModel: TaskListViewModel)
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             didInstantiate tagCollectionViewModel: TagCollectionViewModel)
}

class HomeScreenViewModel {
    
    private(set) var selectedTags: [Tag]
    private(set) var taskModel: TaskModel
    private(set) var tagModel: TagModel
    
    let emptyStateTitleText = Strings.HomeScreen.emptyStateTitle
    let emptyStateSubtitleText = Strings.HomeScreen.emptyStateSubtitle
    let emptyStateOrText = Strings.HomeScreen.emptyStateOr
    let importFromRemindersText = Strings.HomeScreen.importFromReminders
    
    weak var delegate: HomeScreenViewModelDelegate?
    
    init(taskModel: TaskModel, tagModel: TagModel, selectedTags: [Tag],
         taskListViewModelType: TaskListViewModel.Type) {
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
        self.taskListViewModelType = taskListViewModelType
    }
    
    private let taskListViewModelType: TaskListViewModel.Type
    lazy var taskListViewModel: TaskListViewModel = {
        let taskListViewModel = taskListViewModelType.init(model: taskModel)
        delegate?.homeScreenViewModel(self, didInstantiate: taskListViewModel)
        
        return taskListViewModel
    }()
    
    lazy var tagCollectionViewModel: TagCollectionViewModel = {
        let tagCollectionViewModel = TagCollectionViewModel(model: tagModel,
                                                            filtering: true,
                                                            selectedTags: selectedTags)
        return tagCollectionViewModel
    }()
    
    var bigTitleText: String {
        if let tag = selectedTags.first {
            return tag.title!
        } else {
            return Strings.HomeScreen.title
        }
    }
    
    func unSelectBigTitle(tag: Tag) {
        tagCollectionViewModel.selectedTagEvent.onNext(tag)
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
        //TODO: uncomment when available
        //        if #available(iOS 12.0, *) {
        //            activity.isEligibleForPrediction = true
        //        }
        
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
