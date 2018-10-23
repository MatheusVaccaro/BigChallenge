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
    fileprivate var taskDetailsViewController: AddDetailsViewController!
    
    fileprivate var tagCollectionViewModel: TagCollectionViewModel
    
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    
    fileprivate var task: Task?
    var selectedTags: [Tag]
    
    var presentTaskInteractiveAnimationController: PresentTaskInteractiveAnimationController?
    fileprivate var dismissTaskInteractiveAnimationController: DismissTaskInteractiveAnimationController?

    weak var delegate: CoordinatorDelegate?
    
    init(task: Task? = nil,
         presenter: UINavigationController,
         taskModel: TaskModel,
         tagModel: TagModel,
         selectedTags: [Tag],
         tagCollectionViewModel: TagCollectionViewModel) {
        
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.presenter = presenter
        self.childrenCoordinators = []
        self.task = task
        self.selectedTags = selectedTags
        self.tagCollectionViewModel = tagCollectionViewModel
        
        tagCollectionViewModel.selectedTags = selectedTags

        print("+++ INIT NewTaskCoordinator")
    }
    
    deinit {
        print("--- DEINIT NewTaskCoordinator")
    }
    
    func start() {
        tagCollectionViewController = TagCollectionViewController.instantiate()
        newTaskViewController = NewTaskViewController.instantiate()
        taskDetailsViewController = AddDetailsViewController.instantiate()
        creationFrameViewController = TaskCreationFrameViewController.instantiate()
        
        let newTaskViewModel =
            NewTaskViewModel(selectedTags: selectedTags)
        let taskDetailsViewModel =
            AddTaskDetailsViewModel(selectedTags: selectedTags)
        let creationFrameViewModel =
            TaskCreationViewModel(taskModel: taskModel, taskDetails: taskDetailsViewModel,
                                  newTaskViewModel: newTaskViewModel, selectedTags: selectedTags)
        
        creationFrameViewModel.edit(task)
        
        tagCollectionViewController.viewModel = tagCollectionViewModel
        tagCollectionViewModel.filtering = false
        newTaskViewController.viewModel = newTaskViewModel
        taskDetailsViewController!.viewModel = taskDetailsViewModel
        creationFrameViewController.viewModel = creationFrameViewModel
        
        tagCollectionViewModel.delegate = self
        creationFrameViewModel.delegate = self
        
        tagCollectionViewModel.uiDelegate = tagCollectionViewController
        creationFrameViewModel.uiDelegate = creationFrameViewController
        newTaskViewModel.uiDelegate = newTaskViewController
        
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
                                                  presenter: modalPresenter,
                                                  model: tagModel)
        newTagCoordinator.delegate = self
        addChild(coordinator: newTagCoordinator)
        newTagCoordinator.start()
    }
    
    fileprivate func showEditTag(_ tag: Tag) {
        let editTagCoordinator = NewTagCoordinator(tag: tag,
                                                   presenter: modalPresenter,
                                                   model: tagModel)
        editTagCoordinator.delegate = self
        addChild(coordinator: editTagCoordinator)
        editTagCoordinator.start()
    }
    
    func update(selectedTags: [Tag]) {
        creationFrameViewController.viewModel.set(tags: selectedTags)
    }
    
    private func configureModalPresenter() {
        modalPresenter.navigationBar.shadowImage = UIImage()
        
        if UIAccessibility.isReduceMotionEnabled {
            modalPresenter.modalTransitionStyle = .crossDissolve
        } else {
            modalPresenter.transitioningDelegate = self
        }
        
        modalPresenter.navigationBar.setBackgroundImage(UIImage(), for: .default)
        modalPresenter.navigationBar.shadowImage = UIImage()
        modalPresenter.view.backgroundColor = .clear
        
        modalPresenter.navigationBar.prefersLargeTitles = true
        modalPresenter.navigationBar.isTranslucent = true
        modalPresenter.navigationBar.largeTitleTextAttributes = largeTitleAttributes
        modalPresenter.modalPresentationStyle = .overCurrentContext
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNavigationTap))
        modalPresenter.navigationBar.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleNavigationTap() {
        guard modalPresenter.children.count == 1 else { return }
        dismissViewController()
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
        creationFrameViewController.present(taskDetailsViewController)
        creationFrameViewController.present(tagCollectionViewController)
        
        self.dismissTaskInteractiveAnimationController =
            DismissTaskInteractiveAnimationController(presenter: modalPresenter,
                                                      view: creationFrameViewController.blurView,
                                                      completionHandler: { [unowned self] in
                                                        self.delegate?.shouldDeinitCoordinator(self)
                                                    }
            )
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
        guard let _ = presenting.children.first as? HomeScreenViewController else { return nil }
        return PresentTaskAnimationController()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let _ = dismissed.children.first as? TaskCreationFrameViewController else { return nil }
        return DismissTaskAnimationController()
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = presentTaskInteractiveAnimationController else { return nil }
        return animator.interactionInProgress ? animator : nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = dismissTaskInteractiveAnimationController else { return nil }
        return animator.interactionInProgress ? animator : nil
    }
}

extension NewTaskCoordinator: TagCollectionViewModelDelegate {
    func didUpdateSelectedTags(_ selectedTags: [Tag]) {
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
