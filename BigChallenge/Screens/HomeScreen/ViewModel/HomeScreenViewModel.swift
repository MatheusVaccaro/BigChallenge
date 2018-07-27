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
    
    lazy var taskListViewModel: TaskListViewModel = {
        return TaskListViewModel(model: taskModel)
    }()
    
    lazy var tagListViewModel: TagCollectionViewModel = {
        return TagCollectionViewModel(model: tagModel, filtering: true)
    }()
    
    private(set) var taskModel: TaskModel
    private(set) var tagModel: TagModel
    
    init(taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
    }
    
    func tagCollectionViewModel(with selectedTags: [Tag] = []) -> TagCollectionViewModel {
        return TagCollectionViewModel(model: tagModel, filtering: true, selectedTags: selectedTags)
    }
}
