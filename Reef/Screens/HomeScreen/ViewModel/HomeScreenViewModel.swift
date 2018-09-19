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
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel, willEdit task: Task)
    
    func homeScreenViewModelWillImportFromReminders(_ homeScreenViewModel: HomeScreenViewModel)
    
    func homeScreenViewModelShouldShowImportFromRemindersOption(_ homeScreenViewModel: HomeScreenViewModel) -> Bool
    
    func homeScreenViewModelWillAddTag(_ homeScreenViewModel: HomeScreenViewModel)
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             didInstantiate taskListViewModel: TaskListViewModel)
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             didInstantiate tagCollectionViewModel: TagCollectionViewModel)
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             didChange selectedTags: [Tag])
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
    
    required init(taskModel: TaskModel, tagModel: TagModel, selectedTags: [Tag],
                  taskListViewModelType: TaskListViewModel.Type,
                  tagCollectionViewModelType: TagCollectionViewModel.Type) {
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
        self.taskListViewModelType = taskListViewModelType
        self.tagCollectionViewModelType = tagCollectionViewModelType
    }
    
    private let taskListViewModelType: TaskListViewModel.Type
    lazy var taskListViewModel: TaskListViewModel = {
        let taskListViewModel = taskListViewModelType.init(model: taskModel)
        delegate?.homeScreenViewModel(self, didInstantiate: taskListViewModel)
        
        return taskListViewModel
    }()
    
    private let tagCollectionViewModelType: TagCollectionViewModel.Type
    lazy var tagCollectionViewModel: TagCollectionViewModel = {
        let tagCollectionViewModel = tagCollectionViewModelType.init(model: tagModel,
                                                                     filtering: true,
                                                                     selectedTags: selectedTags)
        delegate?.homeScreenViewModel(self, didInstantiate: tagCollectionViewModel)
        
        return tagCollectionViewModel
    }()
    
    var bigTitleText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "d MMM"
        let title = dateFormatter.string(from: Date())
        
        return title
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
        delegate?.homeScreenViewModel(self, didChange: selectedTags)
        print("selected tags are: \(selectedTags.map { $0.title })")
    }
    
    func updateUserActivity(_ activity: NSUserActivity) {
        guard !selectedTags.isEmpty else { return }
        activity.addUserInfoEntries(from: ["selectedTagIDs" : selectedTags.map { $0.id!.description }])
        
        activity.title = userActivityTitle
        
        activity.becomeCurrent()
    }
}
