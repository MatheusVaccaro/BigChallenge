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
    
    fileprivate var newTaskTableViewController: NewTaskTableViewController?
    fileprivate let taskModel: TaskModel
    fileprivate let tagModel: TagModel
    fileprivate var task: Task?
    fileprivate let isEditing: Bool
    fileprivate var modalPresenter: UINavigationController?
    
    weak var delegate: CoordinatorDelegate?
    
    init(task: Task? = nil, isEditing: Bool, presenter: UINavigationController, taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
        self.presenter = presenter
        self.childrenCoordinators = []
        self.isEditing = isEditing
        self.task = task
    }
    
    func start() {
        let newTaskTableViewController = NewTaskTableViewController.instantiate()
        self.newTaskTableViewController = newTaskTableViewController
        
        let newTaskViewModel = NewTaskViewModel(task: task, isEditing: isEditing, taskModel: taskModel)
        newTaskViewModel.delegate = self
        newTaskTableViewController.viewModel = newTaskViewModel
        
        let tagCollectionViewModel = TagCollectionViewModel(model: tagModel)
        newTaskTableViewController.tagCollectionViewModel = tagCollectionViewModel
        
        let modalPresenter = UINavigationController(rootViewController: newTaskTableViewController)
        self.modalPresenter = modalPresenter
        
        presenter.present(modalPresenter, animated: true, completion: nil)
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
    
    private func dismissViewController() {
        presenter.dismiss(animated: true, completion: nil)
        delegate?.shouldDeinitCoordinator(self)
    }
    
}
