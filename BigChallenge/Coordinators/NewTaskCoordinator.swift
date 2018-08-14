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
    
    fileprivate var taskFrameViewController: CreationFrameViewController?
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
            ? task!.tags!.allObjects as! [Tag]
            : selectedTags
    }
    
    func start() {
        // New Task
        let newTaskViewController = NewTaskViewController.instantiate()
        self.newTaskViewController = newTaskViewController

        let newTaskViewModel = NewTaskViewModel(task: task,
                                                isEditing: isEditing,
                                                taskModel: taskModel)
        newTaskViewController.viewModel = newTaskViewModel

        let tagCollectionViewModel = TagCollectionViewModel(model: tagModel,
                                                            filtering: false,
                                                            selectedTags: selectedTags)
        newTaskViewController.tagCollectionViewModel = tagCollectionViewModel
        
        // More Options
        let moreOptionsViewController = MoreOptionsViewController.instantiate()
        
        let locationInputViewController = LocationInputView.instantiate()
        let locationInputViewModel = locationInputViewController.viewModel
		
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
        
        creationFrameViewController
            .configurePageViewController(with: [newTaskViewController, moreOptionsViewController])

        // Modal Presenter
        let modalPresenter = UINavigationController(rootViewController: creationFrameViewController)
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

extension NewTaskCoordinator: CreationFrameViewModelDelegate {
    
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

extension DateInputViewModel {
    convenience init(with task: Task?) {
        guard let task = task else {
            self.init()
            return
        }
        
        if let triggerDate = task.notificationOptions.triggerDate {
            let date = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
            let timeOfDay = Calendar.current.dateComponents([.hour, .minute, .second], from: triggerDate)
            let frequency = task.notificationOptions.frequency
            self.init(date: date, timeOfDay: timeOfDay, frequency: frequency)
            
        } else {
            self.init()
        }
    }
}
