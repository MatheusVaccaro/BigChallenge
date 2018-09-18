//
//  NewTaskCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 26/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import ReefKit

class NewTaskCoordinator: Coordinator {
    
    fileprivate let presenter: UINavigationController
    var childrenCoordinators: [Coordinator]
    
    fileprivate var creationFrameViewController: TaskCreationFrameViewController!
    fileprivate var newTaskViewController: NewTaskViewController?
    fileprivate var moreOptionsViewController: MoreOptionsViewController?
    
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    
    fileprivate var selectedTags: [Tag]
    fileprivate let viewController: HomeScreenViewController
    
    weak var delegate: CoordinatorDelegate?
    
    init(presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag] = [],
         in viewController: HomeScreenViewController) {
        
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.presenter = presenter
        self.childrenCoordinators = []
        
        self.viewController = viewController
        
        self.selectedTags = selectedTags
        
        print("+++ INIT NewTaskCoordinator")
    }
    
    deinit {
        print("--- DEINIT NewTaskCoordinator")
    }
    
    func start() {
        // new task (title)
        let newTaskViewController = NewTaskViewController.instantiate()
        newTaskViewController.delegate = self
        newTaskViewController.viewModel = NewTaskViewModel(taskModel: taskModel)
        
        self.newTaskViewController = newTaskViewController
    
        // Task Frame
        let creationFrameViewController = TaskCreationFrameViewController.instantiate()
        let creationFrameViewModel = TaskCreationViewModel(taskModel: taskModel)
        creationFrameViewModel.delegate = self
        
        creationFrameViewController.viewModel = creationFrameViewModel
        self.creationFrameViewController = creationFrameViewController

        newTaskViewController.viewModel.outputDelegate = creationFrameViewModel
        
        viewController.setupAddTask(viewController: creationFrameViewController)
        self.creationFrameViewController.present(self.newTaskViewController!)
        showMoreOptions()
    }
    
    func edit(_ task: Task) {
        selectedTags = task.allTags
        creationFrameViewController.viewModel.task = task
        newTaskViewController?.viewModel.edit(task)
        moreOptionsViewController?.viewModel.task = task
        viewController.prepareToPresentAddTask()
    }
    
    fileprivate func showMoreOptions() {
        moreOptionsViewController = MoreOptionsViewController.instantiate()
        moreOptionsViewController?.delegate = self
        
        moreOptionsViewController!.viewModel = MoreOptionsViewModel(task: nil)
        
        moreOptionsViewController!.viewModel.delegate = creationFrameViewController.viewModel
        
        creationFrameViewController.present(moreOptionsViewController!)
    }
    
    fileprivate func showLocationInput() {
        let locationInputView = LocationInputView.instantiate()
        locationInputView.viewModel = moreOptionsViewController!.viewModel.locationInputViewModel

        presenter.pushViewController(locationInputView, animated: true)
    }
    
    fileprivate func showDateInput() {
        let dateInputView = DateInputViewController.instantiate()
        dateInputView.viewModel = moreOptionsViewController!.viewModel.dateInputViewModel
        
        presenter.pushViewController(dateInputView, animated: true)
    }
    
    fileprivate func showNewTag() {
        let newTagCoordinator = NewTagCoordinator(tag: nil,
                                                  presenter: presenter,
                                                  model: tagModel)
        newTagCoordinator.delegate = self
        addChild(coordinator: newTagCoordinator)
        newTagCoordinator.start()
    }
}

extension NewTaskCoordinator: MoreOptionsDelegate {
    func shouldPresentViewForDateInput() {
        showDateInput()
    }
    
    func shouldPresentViewForLocationInput() {
        showLocationInput()
    }
}

extension NewTaskCoordinator {
    private func dismissViewController() {
        presenter.dismiss(animated: true, completion: nil)
        delegate?.shouldDeinitCoordinator(self)
    }
}

extension NewTaskCoordinator: CoordinatorDelegate {
    func shouldDeinitCoordinator(_ coordinator: Coordinator) {
        releaseChild(coordinator: coordinator)
    }
}

extension NewTaskCoordinator: TaskCreationDelegate {
    func didTapAddTask() {
        viewController.prepareToPresentAddTask()
    }
    
    func didPanAddTask() {
        viewController.didPanAddTask()
    }
}

extension NewTaskCoordinator: NewTaskDelegate {
    func shouldPresentMoreOptions() {
        viewController.prepareToPresentMoreOptions()
    }
    
    func shouldHideMoreOptions() {
        viewController.prepareToPresentAddTask()
    }
}
