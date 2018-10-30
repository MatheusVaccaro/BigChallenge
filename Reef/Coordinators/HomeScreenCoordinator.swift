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
         selectedTags: [Tag],
         remindersImporter: RemindersImporter) {
        
        self.presenter = presenter
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.selectedTags = selectedTags
        
        self.childrenCoordinators = []
        
        self.remindersImporter = remindersImporter
        remindersImporter.delegate = self
        
        #if DEBUG
        print("+++ INIT HomeScreenCoordinator")
        #endif
    }
    
    #if DEBUG
    deinit {
        print("--- DEINIT HomeScreenCoordinator")
    }
    #endif

    func start() {
        homeScreenViewController = HomeScreenViewController.instantiate()
        
        taskListViewController = TaskListViewController.instantiate()
        tagCollectionViewController = TagCollectionViewController.instantiate()
        
        tagCollectionViewModel = TagCollectionViewModel(model: tagModel,
                                                        filtering: true,
                                                        selectedTags: selectedTags)
        
        taskListViewModel = TaskListViewModel(model: taskModel,
                                              selectedTags: selectedTags)
        
        homeScreenViewModel = HomeScreenViewModel(taskModel: taskModel,
                                                  tagModel: tagModel,
                                                  selectedTags: selectedTags,
                                                  taskListViewModel: taskListViewModel,
                                                  tagCollectionViewModel: tagCollectionViewModel)
        
        taskListViewController.viewModel = taskListViewModel
        homeScreenViewController.viewModel = homeScreenViewModel
        tagCollectionViewController.viewModel = tagCollectionViewModel
        
        homeScreenViewController.delegate = self
        homeScreenViewModel.delegate = self
        tagCollectionViewModel.delegate = self
        tagCollectionViewModel.uiDelegate = tagCollectionViewController
        
        presenter.pushViewController(homeScreenViewController!, animated: false)
    }
    
    lazy var newTaskCoordinator: NewTaskCoordinator = {
        let newTaskCoordinator =
            NewTaskCoordinator(presenter: presenter,
                               taskModel: taskModel,
                               tagModel: tagModel,
                               selectedTags: selectedTags,
                               tagCollectionViewModel: tagCollectionViewModel)
        
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        return newTaskCoordinator
    }()
    
    fileprivate func showSettings() {
        let settingsCoordinator = SettingsCoordinator(presenter: presenter)
        
        addChild(coordinator: settingsCoordinator)
        settingsCoordinator.start()
    }

    fileprivate func showNewTask() {
        let newTaskCoordinator =
            NewTaskCoordinator(presenter: presenter,
                               taskModel: taskModel,
                               tagModel: tagModel,
                               selectedTags: selectedTags,
                               tagCollectionViewModel: tagCollectionViewModel)
                                                    
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
                               selectedTags: task.allTags,
                               tagCollectionViewModel: tagCollectionViewModel)
        
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
        if tagCollectionViewModel.delegate !== self {
            tagCollectionViewModel.delegate = self
            tagCollectionViewModel.uiDelegate = tagCollectionViewController
            tagCollectionViewModel.filtering = true
            
            tagCollectionViewModel.reload()
        }
    }
}

extension HomeScreenCoordinator: HomeScreenViewModelDelegate {
    func homeScreenViewModelDidStartSettings(_ homeScreenViewModel: HomeScreenViewModel) {
        showSettings()
    }
    
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

extension HomeScreenCoordinator: RemindersImporterDelegate {
    func remindersImporterDidFinishImport(_ remindersImporter: RemindersImporter) {
        let importedTags = remindersImporter.consumeNewImportedTags()
        let importedTasks = remindersImporter.consumeNewImportedTasks()
        
        tagModel.save(Array(importedTags))
        taskModel.save(Array(importedTasks))
    }
}
