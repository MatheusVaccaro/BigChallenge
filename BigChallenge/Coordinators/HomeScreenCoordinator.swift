//
//  TaskListCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class HomeScreenCoordinator: Coordinator {
    
    var childrenCoordinators: [Coordinator]
    fileprivate let presenter: UINavigationController
    
    fileprivate var homeScreenViewController: HomeScreenViewController?
    fileprivate var taskListViewController: TaskListViewController?
    fileprivate var tagCollectionViewController: TagCollectionViewController?
    
    fileprivate let persistence: Persistence
    fileprivate var taskModel: TaskModel
    fileprivate var tagModel: TagModel
    fileprivate var selectedTags: [Tag]
    
    init(presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         persistence: Persistence,
         selectedTags: [Tag]) {
        
        self.presenter = presenter
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
        
        self.childrenCoordinators = []
        self.persistence = persistence
    }

    func start() {
        let homeScreenViewController = HomeScreenViewController.instantiate()
        let homeScreenViewModel = HomeScreenViewModel(taskModel: taskModel, tagModel: tagModel, selectedTags: selectedTags)
        homeScreenViewController.viewModel = homeScreenViewModel

        homeScreenViewController.delegate = self
        self.homeScreenViewController = homeScreenViewController
        
        // TODO: Reestructure HomeScreen according to the architecture
        homeScreenViewModel.tagCollectionViewModelDelegate = self
        
        presenter.isNavigationBarHidden = true
        presenter.pushViewController(homeScreenViewController, animated: false)
    }

    fileprivate func showNewTask(selectedTags: [Tag]) {
        let newTaskCoordinator = NewTaskCoordinator(task: nil,
                                                    presenter: presenter,
                                                    taskModel: taskModel,
                                                    tagModel: tagModel,
                                                    selectedTags: selectedTags)
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        newTaskCoordinator.start()
    }
    
    fileprivate func showEditTask(_ task: Task) {
        let newTaskCoordinator = NewTaskCoordinator(task: task,
                                                    presenter: presenter,
                                                    taskModel: taskModel,
                                                    tagModel: tagModel)
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        newTaskCoordinator.start()
    }
    
    fileprivate func showNewTag() {
        let newTagCoordinator = NewTagCoordinator(tag: nil,
                                                  presenter: presenter,
                                                  model: tagModel)
        newTagCoordinator.delegate = self
        addChild(coordinator: newTagCoordinator)
        newTagCoordinator.start()
    }
    
    fileprivate func showEditTag(_ tag: Tag) {
        let editTagCoordinator = NewTagCoordinator(tag: tag,
                                                  presenter: presenter,
                                                  model: tagModel)
        editTagCoordinator.delegate = self
        addChild(coordinator: editTagCoordinator)
        editTagCoordinator.start()
    }
}

extension HomeScreenCoordinator: CoordinatorDelegate {
    func shouldDeinitCoordinator(_ coordinator: Coordinator) {
        releaseChild(coordinator: coordinator)
    }
}

extension HomeScreenCoordinator: HomeScreenViewModelDelegate {
    
    func willAddTask(selectedTags: [Tag]) {
        showNewTask(selectedTags: selectedTags)
    }
    
    func willAddTag() {
        showNewTag()
    }
    
    func will(edit task: Task) {
        showEditTask(task)
    }
}

extension HomeScreenCoordinator: TagCollectionViewModelDelegate {
    
    func willUpdate(tag: Tag) {
        showEditTag(tag)
    }

}
