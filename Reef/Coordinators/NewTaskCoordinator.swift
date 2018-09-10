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
        
        // edit task
        //TODO: move to respective viewModels
        if let task = self.task {
//            locationInputViewController.outputlocation = location
//            locationInputViewController.arriving = task.isArriving
//            creationFrameViewModel.task = task
//            creationFrameViewModel.doneButtonObservable.onNext(true)
        }
        
        // Modal Presenter
        let modalPresenter = UINavigationController(rootViewController: creationFrameViewController)
        modalPresenter.isNavigationBarHidden = true
        self.modalPresenter = modalPresenter
        
        presenter.present(modalPresenter, animated: true, completion: nil)
    }
    
    fileprivate func showMoreOptions() {
        // More Options
        moreOptionsViewController = MoreOptionsViewController.instantiate()
        
        let moreOptionsViewModel = MoreOptionsViewModel()
        
        moreOptionsViewController!.viewModel = moreOptionsViewModel
        
        taskFrameViewController.present(moreOptionsViewController!)
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
    
//    fileprivate func showMoreOptions() {
        // init moreOptions coordinator
        // moreOptionsCoordinator presenter SHOULD be modalPresenter in this case
        // set coordinator's delegate to self
        // call addChild(moreOptionsCoordinator)
        // call .start() of moreOptionsCoordinator
        
        // IMPORTANT!
        // Use this Coordinator as exemple
        // Remember to call shouldDeinitCoordinator when needed
//    }
    
}

extension NewTaskCoordinator {
    
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

//extension NewTaskCoordinator: CreationFrameViewControllerDelegate { // used instead of segues to load subviews (?)
//    func viewDidLoad(in viewController: CreationFrameViewController) {
//        let newTaskViewController = NewTaskViewController.instantiate()
//
//        self.newTaskViewController = newTaskViewController
//        newTaskViewController.viewModel = newTaskViewModel
//    }
//}
