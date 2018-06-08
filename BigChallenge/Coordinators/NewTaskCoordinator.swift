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
    
    fileprivate let persistence: Persistence
    fileprivate let presenter: UINavigationController
    fileprivate var modalPresenter: UINavigationController?
    fileprivate var newTaskTableViewController: NewTaskTableViewController?
    fileprivate let task: Task
    fileprivate let isEditing: Bool
    var childrenCoordinators: [Coordinator]
    
    weak var delegate: CoordinatorDelegate?
    
    init(task: Task, isEditing: Bool, presenter: UINavigationController, persistence: Persistence) {
        self.persistence = persistence
        self.presenter = presenter
        self.childrenCoordinators = []
        self.task = task
        self.isEditing = isEditing
    }
    
    func start() {
        let newTaskTableViewController = NewTaskTableViewController.instantiate()
        self.newTaskTableViewController = newTaskTableViewController
        
        let newTaskViewModel = NewTaskViewModel(task: task, isEditing: isEditing, persistence: persistence)
        newTaskViewModel.delegate = self
        newTaskTableViewController.viewModel = newTaskViewModel
        
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
