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

class NewTaskCoordinator: NSObject, Coordinator {
    
    fileprivate let presenter: UINavigationController
    fileprivate var modalPresenter: UINavigationController!
    var childrenCoordinators: [Coordinator]
    
    fileprivate var creationFrameViewController: TaskCreationFrameViewController!
    fileprivate var tagCollectionViewController: TagCollectionViewController!
    fileprivate var newTaskViewController: NewTaskViewController!
    fileprivate var moreOptionsViewController: MoreOptionsViewController!
    
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    
    fileprivate var task: Task?
    fileprivate var selectedTags: [Tag]
    
    weak var delegate: CoordinatorDelegate?
    
    init(task: Task? = nil,
         presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag]) {
        
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.presenter = presenter
        self.childrenCoordinators = []
        self.task = task
        self.selectedTags = selectedTags
        
        print("+++ INIT NewTaskCoordinator")
    }
    
    deinit {
        print("--- DEINIT NewTaskCoordinator")
    }
    
    func start() {
        tagCollectionViewController = TagCollectionViewController.instantiate()
        newTaskViewController = NewTaskViewController.instantiate()
        moreOptionsViewController = MoreOptionsViewController.instantiate()
        creationFrameViewController = TaskCreationFrameViewController.instantiate()
        
        let tagCollectionViewModel =
            TagCollectionViewModel(model: tagModel, filtering: false, selectedTags: selectedTags)
        let newTaskViewModel = NewTaskViewModel()
        let moreOptionsViewModel = MoreOptionsViewModel()
        let creationFrameViewModel =
            TaskCreationViewModel(taskModel: taskModel,
                                  moreOptionsViewModel: moreOptionsViewModel,
                                  newTaskViewModel: newTaskViewModel)
        
        creationFrameViewModel.edit(task)
        
        tagCollectionViewController.viewModel = tagCollectionViewModel
        newTaskViewController.viewModel = newTaskViewModel
        moreOptionsViewController!.viewModel = moreOptionsViewModel
        creationFrameViewController.viewModel = creationFrameViewModel
        
        tagCollectionViewModel.delegate = self
        creationFrameViewModel.delegate = self
        creationFrameViewModel.uiDelegate = creationFrameViewController
        
        modalPresenter = UINavigationController(rootViewController: creationFrameViewController)
        configureModalPresenter()
        
        presenter.present(modalPresenter, animated: true) {
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: nil)
        }
    }
    
    func startAddTask() {
        newTaskViewController.start()
    }
    
    fileprivate func showNewTag() {
        let newTagCoordinator = NewTagCoordinator(tag: nil,
                                                  presenter: presenter,
                                                  model: tagModel)
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
    
    func update(selectedTags: [Tag]) {
        creationFrameViewController.viewModel.set(tags: selectedTags)
    }
    
    private func configureModalPresenter() {
        modalPresenter.transitioningDelegate = self
        modalPresenter.navigationBar.shadowImage = UIImage()
        modalPresenter.navigationBar.prefersLargeTitles = true
        modalPresenter.navigationBar.isTranslucent = false
        modalPresenter.navigationBar.largeTitleTextAttributes =
            [ NSAttributedString.Key.font : UIFont.font(sized: 34, weight: .bold, with: .largeTitle, fontName: .barlow) ]
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
    
    func viewDidLoad() {
        creationFrameViewController.present(newTaskViewController)
        creationFrameViewController.present(moreOptionsViewController)
        creationFrameViewController.present(tagCollectionViewController)
    }
    
    func dismiss() {
        dismissViewController()
    }
    
    func didCreateTask() {
        dismissViewController()
    }

}

extension NewTaskCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let homeScreenViewController = presenting.children.first else { return nil }
        let swipeInteractionController = SwipeInteractionController(viewController: homeScreenViewController)
        return TaskCreationFramePresentAnimationController(interactionController: swipeInteractionController)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let dismissedViewController = dismissed.children.first as? TaskCreationFrameViewController else { return nil }
        return TaskCreationFrameDismissAnimationController()
    }
    
    // TODO: Fix interactive gesture
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? TaskCreationFramePresentAnimationController,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else { return nil }
        return interactionController
    }
}

extension NewTaskCoordinator: TagCollectionViewModelDelegate {
    
    func didUpdate(_ selectedTags: [Tag]) {
        creationFrameViewController.viewModel.set(tags: selectedTags)
    }
    
    func didClickUpdate(tag: Tag) {
        showEditTag(tag)
    }
    
    func didclickAddTag() {
        showNewTag()
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
        
        modalPresenter.pushViewController(inputView!, animated: true)
    }

}
