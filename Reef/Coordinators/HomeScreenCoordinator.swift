//
//  TaskListCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import ReefKit

class HomeScreenCoordinator: Coordinator {
    
    var childrenCoordinators: [Coordinator]
    private let presenter: UINavigationController
    
    private let remindersImporter: RemindersImporter
    private var taskModel: TaskModel
    private var tagModel: TagModel
    private var selectedTags: [Tag]
    
    private var homeScreenViewController: HomeScreenViewController!
    private var taskListViewController: TaskListViewController!
    private var tagCollectionViewController: TagCollectionViewController!
    
    private var homeScreenViewModel: HomeScreenViewModel!
    private var taskListViewModel: TaskListViewModel!
    private var tagCollectionViewModel: TagCollectionViewModel!
    
    private var presentTaskInteractiveAnimationController: PresentTaskInteractiveAnimationController?
    
    init(presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag]) {
        
        self.presenter = presenter
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
        
        self.childrenCoordinators = []
        
        self.remindersImporter = RemindersImporter(taskModel: taskModel, tagModel: tagModel)
        
        print("+++ INIT HomeScreenCoordinator")
    }
    
    deinit {
        print("--- DEINIT HomeScreenCoordinator")
    }

    func start() {
        homeScreenViewController = HomeScreenViewController.instantiate()
        
        taskListViewController = TaskListViewController.instantiate()
        taskListViewModel = TaskListViewModel(model: taskModel)
        taskListViewController.viewModel = taskListViewModel
        
        tagCollectionViewController = TagCollectionViewController.instantiate()
        tagCollectionViewModel = TagCollectionViewModel(model: tagModel,
                                                        filtering: true,
                                                        selectedTags: selectedTags)
        
        homeScreenViewModel = HomeScreenViewModel(taskModel: taskModel,
                                                  tagModel: tagModel,
                                                  selectedTags: selectedTags,
                                                  taskListViewModel: taskListViewModel,
                                                  tagCollectionViewModel: tagCollectionViewModel)
        
        homeScreenViewController.delegate = self
        homeScreenViewModel.delegate = self
        tagCollectionViewModel.delegate = self

        homeScreenViewController.viewModel = homeScreenViewModel
        tagCollectionViewController.viewModel = tagCollectionViewModel
        
        presenter.pushViewController(homeScreenViewController!, animated: false)
    }
    
    lazy var newTaskCoordinator: NewTaskCoordinator = {
        let newTaskCoordinator =
            NewTaskCoordinator(presenter: presenter,
                               taskModel: taskModel,
                               tagModel: tagModel,
                               selectedTags: selectedTags)
        
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        return newTaskCoordinator
    }()

    fileprivate func showNewTask() {
        let newTaskCoordinator =
            NewTaskCoordinator(presenter: presenter,
                               taskModel: taskModel,
                               tagModel: tagModel,
                               selectedTags: selectedTags)
                                                    
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        newTaskCoordinator.start()
    }
    
    fileprivate func showEditTask(_ task: Task) {
        let newTaskCoordinator =
            NewTaskCoordinator(task: task,
                               presenter: presenter,
                               taskModel: taskModel,
                               tagModel: tagModel,
                               selectedTags: task.allTags)
        
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
    func homeScreenViewModelDidStartAddTask(_ homeScreenViewModel: HomeScreenViewModel) {
        showNewTask()
    }
    
    func homeScreenViewModel(_ homeScreenViewModel: HomeScreenViewModel, willEdit task: Task) {
        showEditTask(task)
    }
    
    func homeScreenViewModelWillImportFromReminders(_ homeScreenViewModel: HomeScreenViewModel) {
        remindersImporter.requestAndImport()
    }
    
    func homeScreenViewModelShouldShowImportFromRemindersOption(_ homeScreenViewModel: HomeScreenViewModel) -> Bool {
        return !RemindersImporter.isImportingDefined
    }
}

extension HomeScreenCoordinator: TagCollectionViewModelDelegate {
    func didUpdateSelectedTags(_ selectedTags: [Tag]) {
        self.selectedTags = selectedTags
        presentTaskInteractiveAnimationController?.taskCoordinator?.selectedTags = selectedTags
        
        homeScreenViewModel.updateSelectedTagsIfNeeded(selectedTags)
        
        let relatedTags = tagCollectionViewModel
            .filteredTags.filter { !selectedTags.contains($0) }
        
        taskListViewModel
            .filterTasks(with: selectedTags, relatedTags: relatedTags)
        
        if let activity = homeScreenViewController.userActivity {
            homeScreenViewController.updateUserActivityState(activity)
        }
        
        if !selectedTags.isEmpty {
            Answers.logCustomEvent(withName: "filtered with tag",
                                   customAttributes: ["numberOfFilteredTags" : selectedTags.count])
        }
    }
    
    func didClickUpdate(tag: Tag) {
        showEditTag(tag)
    }
    
    func didclickAddTag() {
        showNewTag()
    }
}

extension HomeScreenCoordinator: HomeScreenViewControllerDelegate {
    func viewDidLoad() {
        let interactiveAnimation =
            PresentTaskInteractiveAnimationController(view: homeScreenViewController!.pullDownView,
                                                      taskCoordinator: newTaskCoordinator)
        
        self.presentTaskInteractiveAnimationController = interactiveAnimation
        newTaskCoordinator.presentTaskInteractiveAnimationController = interactiveAnimation
        
        homeScreenViewController!
            .setupTaskList(viewModel: taskListViewModel, viewController: taskListViewController!)
        homeScreenViewController!
            .setupTagCollection(viewModel: tagCollectionViewModel, viewController: tagCollectionViewController!)
    }
}
