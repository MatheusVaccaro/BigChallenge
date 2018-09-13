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
    
    fileprivate var taskFrameViewController: TaskCreationFrameViewController!
    fileprivate var newTaskViewController: NewTaskViewController?
    fileprivate var moreOptionsViewController: MoreOptionsViewController?
    
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    
    fileprivate let selectedTags: [Tag]
    fileprivate var task: Task?
    fileprivate let isEditing: Bool
    fileprivate let viewController: HomeScreenViewController
    
    fileprivate var location: CLCircularRegion?
    fileprivate var date: Date?
    
    weak var delegate: CoordinatorDelegate?
    
    init(task: Task? = nil,
         presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag] = [],
         in viewController: HomeScreenViewController) {
        
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.presenter = presenter
        self.childrenCoordinators = []
        self.isEditing = task != nil
        self.task = task
        
        self.viewController = viewController
        
        self.selectedTags = isEditing
            ? task!.allTags
            : selectedTags
        
        print("+++ INIT NewTaskCoordinator")
    }
    
    deinit {
        print("--- DEINIT NewTaskCoordinator")
    }
    
    func start() {
        // new task (title)
        let newTaskViewController = NewTaskViewController.instantiate()
        
        let newTaskViewModel = NewTaskViewModel(task: task, taskModel: taskModel)
        
        newTaskViewController.viewModel = newTaskViewModel
        
        self.newTaskViewController = newTaskViewController
    
        // Task Frame
        let creationFrameViewController = TaskCreationFrameViewController.instantiate()
        let creationFrameViewModel = TaskCreationViewModel()
        
        creationFrameViewController.viewModel = creationFrameViewModel
        self.taskFrameViewController = creationFrameViewController
        
        viewController.setupAddTask(viewModel: creationFrameViewModel, viewController: creationFrameViewController)
        
        self.taskFrameViewController.present(self.newTaskViewController!)
        showMoreOptions()//TODO remove
    }
    
    fileprivate func showMoreOptions() {
        // More Options
        moreOptionsViewController = MoreOptionsViewController.instantiate()
        moreOptionsViewController?.delegate = self
        let moreOptionsViewModel = MoreOptionsViewModel(task: self.task)
        
        moreOptionsViewController!.viewModel = moreOptionsViewModel
        
        taskFrameViewController.present(moreOptionsViewController!)
    }
    
    fileprivate func showLocationInput() {
        let locationInputView = LocationInputView.instantiate()
        locationInputView.viewModel = moreOptionsViewController!.viewModel.locationInputViewModel

        presenter.pushViewController(locationInputView, animated: true)
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

//extension NewTaskCoordinator: CreationFrameViewControllerDelegate { // used instead of segues to load subviews (?)
//    func viewDidLoad(in viewController: CreationFrameViewController) {
//        let newTaskViewController = NewTaskViewController.instantiate()
//
//        self.newTaskViewController = newTaskViewController
//        newTaskViewController.viewModel = newTaskViewModel
//    }
//}
