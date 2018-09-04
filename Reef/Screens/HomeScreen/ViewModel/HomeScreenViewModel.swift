//
//  HomeScreenViewModel.swift
//  Reef
//
//  Created by Max Zorzetti on 22/08/18.
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

protocol HomeScreenViewModel: class {
    var selectedTags: [Tag] { get }
    var taskModel: TaskModel { get }
    var tagModel: TagModel { get }
    
    var bigTitleText: String { get }
    var emptyStateTitleText: String { get }
    var emptyStateSubtitleText: String { get }
    var emptyStateOrText: String { get }
    var importFromRemindersText: String { get }
    
    var taskListViewModel: TaskListViewModel { get }
    var tagCollectionViewModel: TagCollectionViewModel { get }
    
    var userActivity: NSUserActivity { get }
    
    var delegate: HomeScreenViewModelDelegate? { get set }
    
    init(taskModel: TaskModel, tagModel: TagModel, selectedTags: [Tag],
         taskListViewModelType: TaskListViewModel.Type,
         tagCollectionViewModelType: TagCollectionViewModel.Type)
    
    func updateSelectedTagsIfNeeded(_ tags: [Tag]?)
    func updateUserActivity(_ activity: NSUserActivity)
}
