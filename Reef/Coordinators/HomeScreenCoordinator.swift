//
//  TaskListCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import ReefKit

class HomeScreenCoordinator: Coordinator {
    
    var childrenCoordinators: [Coordinator]
    private let presenter: UINavigationController
    
    private var homeScreenViewController: HomeScreenViewController?
    private let remindersImporter: RemindersImporter
    private var taskModel: TaskModel
    private var tagModel: TagModel
    private var selectedTags: [Tag]
    
    private let taskListViewModelType: TaskListViewModel.Type
    private var taskListViewController: TaskListViewController?
    
    private let tagCollectionViewModelType: TagCollectionViewModel.Type
    private var tagCollectionViewController: TagCollectionViewController?
    
    init(presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag]) {
        
        self.presenter = presenter
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
        
        self.tagCollectionViewModelType = TagCollectionViewModelImpl.self
        self.taskListViewModelType = TaskListViewModel.self
        
        self.childrenCoordinators = []
        
        self.remindersImporter = RemindersImporter(taskModel: taskModel, tagModel: tagModel)
        //        self.remindersImporter.importIfGranted() TODO: fix
        
        self.taskModel.delegate = self
    }

    func start() {
        let homeScreenViewController = HomeScreenViewController.instantiate()
        let homeScreenViewModel = HomeScreenViewModel(taskModel: taskModel,
                                                      tagModel: tagModel,
                                                      selectedTags: selectedTags,
                                                      taskListViewModelType: taskListViewModelType,
                                                      tagCollectionViewModelType: tagCollectionViewModelType)
        
        homeScreenViewController.viewModel = homeScreenViewModel

        homeScreenViewModel.delegate = self
        self.homeScreenViewController = homeScreenViewController
        
        presenter.pushViewController(homeScreenViewController, animated: false)
    }

    fileprivate func showNewTask(selectedTags: [Tag]) {
        let newTaskCoordinator = NewTaskCoordinator(presenter: presenter,
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
                                                    tagModel: tagModel,
                                                    selectedTags: selectedTags)
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        newTaskCoordinator.start()
    }
    
    fileprivate func showNewTag() {
        let newTagCoordinator = NewTagCoordinator(presenter: presenter, model: tagModel)
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
    func homeScreenViewModelDidEndAddTask(_ homeScreenViewModel: HomeScreenViewModel) {
//        newTaskCoordinator.endAddTask()
    }
    
    func homeScreenViewModelDidStartAddTask(_ homeScreenViewModel: HomeScreenViewModel) {
        showNewTask(selectedTags: selectedTags)
    }
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel, didChange selectedTags: [Tag]) {
//        newTaskCoordinator.update(selectedTags: selectedTags)
    }
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel, willEdit task: Task) {
        showEditTask(task)
    }
    
    func homeScreenViewModelWillAddTag(_ homeScreenViewModel: HomeScreenViewModel) {
        showNewTag()
    }
    
    func homeScreenViewModelWillImportFromReminders(_ homeScreenViewModel: HomeScreenViewModel) {
        remindersImporter.requestAndImport()
    }
    
    func homeScreenViewModelShouldShowImportFromRemindersOption(_ homeScreenViewModel: HomeScreenViewModel) -> Bool {
        return !RemindersImporter.isImportingDefined
    }
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             didInstantiate taskListViewModel: TaskListViewModel) {
        let taskListVC = TaskListViewController.instantiate()
        taskListVC.viewModel = taskListViewModel
        homeScreenViewController?.setupTaskList(viewModel: taskListViewModel, viewController: taskListVC)
    }
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel,
                             didInstantiate tagCollectionViewModel: TagCollectionViewModel) {
        tagCollectionViewModel.delegate = self
        
        let tagCollectionVC = TagCollectionViewController.instantiate()
        tagCollectionVC.viewModel = tagCollectionViewModel
		homeScreenViewController?.setupTagCollection(viewModel: tagCollectionViewModel, viewController: tagCollectionVC)
//        showNewTask(selectedTags: selectedTags)
    }
}

extension HomeScreenCoordinator: TagCollectionViewModelDelegate {
    func willUpdate(tag: Tag) {
        showEditTag(tag)
    }
}

extension HomeScreenCoordinator: TaskModelDelegate {
    func taskModel(_ taskModel: TaskModel, didSave task: Task) {
        remindersImporter.exportTaskToReminders(task)
    }
}
