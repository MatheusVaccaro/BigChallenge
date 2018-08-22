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
    
    fileprivate var taskFrameViewController: CreationFrameViewController?
    fileprivate var newTaskViewController: NewTaskViewController?
    fileprivate var moreOptionsViewController: MoreOptionsViewController?
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    fileprivate let selectedTags: [Tag]
    fileprivate var task: Task?
    fileprivate let isEditing: Bool
    fileprivate var modalPresenter: UINavigationController?
    
    fileprivate var location: CLCircularRegion?
    fileprivate var date: Date?
    
    weak var delegate: CoordinatorDelegate?
    
    init(task: Task? = nil,
         presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag] = []) {
        
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.presenter = presenter
        self.childrenCoordinators = []
        self.isEditing = task != nil
        self.task = task
        
        self.selectedTags = isEditing
            ? task!.allTags
            : selectedTags
    }
    
    func start() {
        // New Task
        let newTaskViewController = NewTaskViewController.instantiate()
        self.newTaskViewController = newTaskViewController

        let newTaskViewModel = NewTaskViewModel(task: task,
                                                taskModel: taskModel)
        
        newTaskViewController.viewModel = newTaskViewModel

        let tagCollectionViewModel = TagCollectionViewModelImpl(model: tagModel,
                                                            filtering: false,
                                                            selectedTags: selectedTags)
        newTaskViewController.tagCollectionViewModel = tagCollectionViewModel
        
        // More Options
        let moreOptionsViewController = MoreOptionsViewController.instantiate()
        
        let locationInputViewController = LocationInputView.instantiate()
        let locationInputViewModel = locationInputViewController.viewModel
        // edit task
        if let task = self.task {
            locationInputViewController.outputlocation = location
            locationInputViewController.arriving = task.isArriving
        }
		
        let dateInputViewModel = DateInputViewModel(with: task)
        let dateInputViewController = DateInputViewController.instantiate()
        dateInputViewController.viewModel = dateInputViewModel
        
        let moreOptionsViewModel = MoreOptionsViewModel(locationInputViewModel: locationInputViewModel,
                                                        dateInputViewModel: dateInputViewModel)
        
        moreOptionsViewController.viewModel = moreOptionsViewModel
        self.moreOptionsViewController = moreOptionsViewController
        moreOptionsViewController.locationCellContent = locationInputViewController
        moreOptionsViewController.timeCellContent = dateInputViewController
    
        // Task Frame
        let creationFrameViewController = CreationFrameViewController.instantiate()
        let creationFrameViewModel = TaskCreationFrameViewModel(mainInfoViewModel: newTaskViewModel,
                                                                detailViewModel: moreOptionsViewModel,
                                                                taskModel: taskModel)
        creationFrameViewModel.delegate = self
        creationFrameViewController.viewModel = creationFrameViewModel
        self.taskFrameViewController = creationFrameViewController
        
        //edit
        if let task = task {
            creationFrameViewModel.task = task
            creationFrameViewModel.doneButtonObservable.onNext(true)
        }
        
        creationFrameViewController
            .configurePageViewController(with: [newTaskViewController, moreOptionsViewController])

        // Modal Presenter
        let modalPresenter = UINavigationController(rootViewController: creationFrameViewController)
        modalPresenter.isNavigationBarHidden = true
        self.modalPresenter = modalPresenter
        
        presenter.present(modalPresenter, animated: true, completion: nil)
    }
    
    fileprivate func showNewTag() {
        guard let modalPresenter = modalPresenter else { return }
        let newTagCoordinator = NewTagCoordinator(tag: nil,
                                                  presenter: modalPresenter,
                                                  model: tagModel)
        newTagCoordinator.delegate = self
        addChild(coordinator: newTagCoordinator)
        newTagCoordinator.start()
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

extension NewTaskCoordinator: CreationFrameViewModelDelegate {
    
    func willAddTag() {
        showNewTag()
    }
    
    func didTapCancelButton() {
        dismissViewController()
    }
    
    func didTapSaveButton() {
        dismissViewController()
    }
    
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


