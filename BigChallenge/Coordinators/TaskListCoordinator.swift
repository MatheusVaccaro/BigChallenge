//
//  TaskListCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 24/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class TaskListCoordinator: Coordinator {
    
    fileprivate let persistence: PersistenceProtocol
    fileprivate let presenter: UINavigationController
    fileprivate var taskListViewController: TaskListViewController?
    fileprivate var model: TaskModel
    var childrenCoordinators: [Coordinator]
    
    init(presenter: UINavigationController, persistence: PersistenceProtocol) {
        self.presenter = presenter
        self.persistence = persistence
        self.model = TaskModel(persistence)
        self.childrenCoordinators = []
    }

    func start() {
        let taskListViewController = TaskListViewController.instantiate()
        self.taskListViewController = taskListViewController
        
        let taskListViewModel = TaskListViewModel(model)
        taskListViewModel.delegate = self
        taskListViewController.viewModel = taskListViewModel
        
        presenter.pushViewController(taskListViewController, animated: true)
    }

    fileprivate func showNewTask() {
        let newTaskCoordinator = NewTaskCoordinator(task: Task ,
                                                    isEditing: false,
                                                    presenter: presenter,
                                                    model: model)
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        newTaskCoordinator.start()
    }
    
    fileprivate func showEditTask(_ task: Task) {
        let newTaskCoordinator = NewTaskCoordinator(task: task,
                                                    isEditing: true,
                                                    presenter: presenter,
                                                    model: model)
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        newTaskCoordinator.start()
    }
}

extension TaskListCoordinator: TaskListViewModelDelegate {
    
    func didTapAddButton() {
        showNewTask()
    }
    
    func didSelectTask(_ task: Task) {
        showEditTask(task)
    }
}

extension TaskListCoordinator: CoordinatorDelegate {
    
    func shouldDeinitCoordinator(_ coordinator: Coordinator) {
        releaseChild(coordinator: coordinator)
    }
}
