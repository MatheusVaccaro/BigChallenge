//
//  NewTaskCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 26/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class NewTaskCoordinator: Coordinator {
    
    fileprivate let presenter: UINavigationController
    var childrenCoordinators: [Coordinator]
    
    fileprivate var taskFrameViewController: TaskFrameViewController?
    fileprivate var newTaskViewController: NewTaskViewController?
    fileprivate var moreOptionsViewController: MoreOptionsViewController?
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    fileprivate let selectedTags: [Tag]
    fileprivate var task: Task?
    fileprivate let isEditing: Bool
    fileprivate var modalPresenter: UINavigationController?
    
    weak var delegate: CoordinatorDelegate?
    
    init(task: Task? = nil,
         isEditing: Bool,
         presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag] = []) {
        
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.presenter = presenter
        self.childrenCoordinators = []
        self.isEditing = isEditing
        self.task = task
        self.selectedTags = selectedTags
    }
    
    func start() {
        // New Task
        let newTaskViewController = NewTaskViewController.instantiate()
        self.newTaskViewController = newTaskViewController

        let newTaskViewModel = NewTaskViewModel(task: task,
                                                isEditing: isEditing,
                                                taskModel: taskModel)
        newTaskViewModel.delegate = self
        newTaskViewController.viewModel = newTaskViewModel

        // Tag Collection
        let tagCollectionViewModel = TagCollectionViewModel(model: tagModel,
                                                            filtering: false,
                                                            selectedTags: selectedTags)
        newTaskViewController.tagCollectionViewModel = tagCollectionViewModel
        
        // More Options
        let moreOptionsViewController = MoreOptionsViewController.instantiate()
        
        let moreOptionsViewModel = MoreOptionsViewModel()
        moreOptionsViewController.viewModel = moreOptionsViewModel
        self.moreOptionsViewController = moreOptionsViewController
        
        let testVC = UIViewController()
        testVC.view.backgroundColor = .orange
        
        let locationInputViewController = LocationInputView.instantiate()
        moreOptionsViewController.locationCellContent = locationInputViewController
        moreOptionsViewController.timeCellContent = testVC
    
        // Task Frame
        let taskFrameViewController = TaskFrameViewController.instantiate()
        self.taskFrameViewController = taskFrameViewController
        taskFrameViewController.configurePageViewController(with: [newTaskViewController, moreOptionsViewController])
        
        // Modal Presenter
        let modalPresenter = UINavigationController(rootViewController: taskFrameViewController)
        modalPresenter.isNavigationBarHidden = true
        self.modalPresenter = modalPresenter
        
        presenter.present(modalPresenter, animated: true, completion: nil)
    }
    
    fileprivate func showMoreOptions() {
        // init moreOptions coordinator
        // moreOptionsCoordinator presenter SHOULD be modalPresenter in this case
        // set coordinator's delegate to self
        // call addChild(moreOptionsCoordinator)
        // call .start() of moreOptionsCoordinator
        
        // IMPORTANT!
        // Use this Coordinator as exemple
        // Remember to call shouldDeinitCoordinator when needed
    }
    
}

extension NewTaskCoordinator: NewTaskViewModelDelegate {
    
    func didTapCancelButton() {
        dismissViewController()
    }
    
    func didTapDoneButton() {
        dismissViewController()
    }
    
    func didTapDeleteTaskButton() {
        dismissViewController()
    }
    
    func didTapMoreOptionsButton() {
        showMoreOptions()
    }
    
    private func dismissViewController() {
        presenter.dismiss(animated: true, completion: nil)
        delegate?.shouldDeinitCoordinator(self)
    }
    
}
