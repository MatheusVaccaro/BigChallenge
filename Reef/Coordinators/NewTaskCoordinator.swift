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
    fileprivate var newTaskViewController: NewTaskViewController!
    fileprivate var moreOptionsViewController: MoreOptionsViewController!
    
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    
    fileprivate var selectedTags: [Tag]
    fileprivate let homeScreen: HomeScreenViewController
    
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
        
        self.homeScreen = viewController
        
        self.selectedTags = selectedTags
        
        print("+++ INIT NewTaskCoordinator")
    }
    
    deinit {
        print("--- DEINIT NewTaskCoordinator")
    }
    
    func start() {
        // new task (title)
        self.newTaskViewController = NewTaskViewController.instantiate()
        let newTaskViewModel = NewTaskViewModel()
        
        newTaskViewModel.delegate = newTaskViewController
        newTaskViewController.viewModel = newTaskViewModel
        
        // more options
        moreOptionsViewController = MoreOptionsViewController.instantiate()
        let moreOptionsViewModel: MoreOptionsViewModel = MoreOptionsViewModel()
        
        moreOptionsViewController!.viewModel = moreOptionsViewModel
    
        // Task Frame
        creationFrameViewController = TaskCreationFrameViewController.instantiate()
        let creationFrameViewModel = TaskCreationViewModel(taskModel: taskModel,
                                                           moreOptionsViewModel: moreOptionsViewModel,
                                                           newTaskViewModel: newTaskViewController.viewModel)
        creationFrameViewModel.delegate = self
        
        creationFrameViewController.viewModel = creationFrameViewModel
        
        homeScreen.setupAddTask(viewController: creationFrameViewController)
        self.creationFrameViewController.present(self.newTaskViewController!)
        creationFrameViewController.present(moreOptionsViewController!)
        
        moreOptionsViewController.accessibilityElementsHidden = true
    }
    
    func edit(_ task: Task) {
        selectedTags = task.allTags
        creationFrameViewController.viewModel.task = task
        homeScreen.prepareToPresentAddTask()
    }
    
    func endAddTask() {
        newTaskViewController.cancelAddTask()
    }
    
    func startAddTask() {
        newTaskViewController.start()
    }
    
    fileprivate func showNewTag() {
        let newTagCoordinator = NewTagCoordinator(tag: nil,
                                                  presenter: presenter,
                                                  model: tagModel, in: homeScreen)
        newTagCoordinator.delegate = self
        addChild(coordinator: newTagCoordinator)
        newTagCoordinator.start()
    }
    
    func update(selectedTags: [Tag]) {
        creationFrameViewController.viewModel.set(tags: selectedTags)
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
    func shouldEscape() {
        homeScreen.prepareToHideAddTask()
        endAddTask()
    }
    
    func didCreateTask() {
        homeScreen.prepareToHideAddTask()
    }
    
    func shouldPresent(viewModel: IconCellPresentable) {
        var inputView: UIViewController?
        
        if let locationViewModel = viewModel as? LocationInputViewModel {
            let locationInput = LocationInputView.instantiate()
            locationInput.viewModel = locationViewModel
            inputView = locationInput
        } else if let dateViewModel = viewModel as? DateInputViewModel {
            let dateInput = DateInputViewController.instantiate()
            dateInput.viewModel = dateViewModel
            inputView = dateInput
        } else if let notesViewModel = viewModel as? NotesInputViewModel {
            let notesInput = NotesInputViewController.instantiate()
            notesInput.viewModel = notesViewModel
            inputView = notesInput
        }
        
        presenter.pushViewController(inputView!, animated: true)
    }
    
    func didTapAddTask() {
        homeScreen.prepareToPresentAddTask()
    }
    
    func didPanAddTask() {
        homeScreen.didPanAddTask()
    }
}

extension NewTaskCoordinator: NewTaskDelegate {
    
    func shouldPresentMoreOptions() {
        homeScreen.prepareToPresentMoreOptions()
        moreOptionsViewController.accessibilityElementsHidden = false
    }
    
    func shouldHideMoreOptions() {
        homeScreen.prepareToPresentAddTask()
        moreOptionsViewController.accessibilityElementsHidden = true
    }
}
