//
//  HomeScreenViewModel.swift
//  Reef
//
//  Created by Max Zorzetti on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol HomeScreenViewModel: class {
    var selectedTags: [Tag] { get }
    var taskModel: TaskModel { get }
    var tagModel: TagModel { get }
    
    var emptyStateTitleText: String { get }
    var emptyStateSubtitleText: String { get }
    var emptyStateOrText: String { get }
    var importFromRemindersText: String { get }
    
    var delegate: HomeScreenViewModelDelegate? { get set }
    
    init(taskModel: TaskModel, tagModel: TagModel, selectedTags: [Tag],
         taskListViewModelType: TaskListViewModel.Type,
         tagCollectionViewModelType: TagCollectionViewModel.Type)
    
    var taskListViewModel: TaskListViewModel { get }
    
    var tagCollectionViewModel: TagCollectionViewModel { get }
    
    var bigTitleText: String { get }
    
    func deselectBigTitle(tag: Tag)
    
    var userActivity: NSUserActivity { get }
    
    func updateSelectedTagsIfNeeded(_ tags: [Tag]?)
    
    func updateUserActivity(_ activity: NSUserActivity)
}
