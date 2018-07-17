//
//  HomeScreenViewModel.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 15/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class HomeScreenViewModel {
    
    lazy var taskListViewModel: TaskListViewModel = {
        return TaskListViewModel(model: taskModel)
    }()
    
    lazy var tagListViewModel: TagCollectionViewModel = {
        return TagCollectionViewModel(model: tagModel)
    }()
    
    private var taskModel: TaskModel
    private var tagModel: TagModel
    
    init(taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
    }
}
