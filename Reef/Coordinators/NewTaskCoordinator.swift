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
        
        modalPresenter.navigationBar.setBackgroundImage(UIImage(), for: .default)
        modalPresenter.navigationBar.shadowImage = UIImage()
        modalPresenter.navigationBar.isTranslucent = true
        modalPresenter.view.backgroundColor = .clear
        modalPresenter.isNavigationBarHidden = true
        
        self.modalPresenter = modalPresenter
        
        presenter.present(modalPresenter, animated: true) {
            self.showMoreOptions()
        }
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

        modalPresenter!.pushViewController(locationInputView, animated: true)
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
