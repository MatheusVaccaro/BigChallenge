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
    
    var childrenCoordinators: [Coordinator]
    fileprivate let presenter: UINavigationController
    fileprivate var taskListViewController: TaskListViewController?
    fileprivate let persistence: Persistence
    fileprivate var model: TaskModel
    
    init(presenter: UINavigationController, model: TaskModel, persistence: Persistence) {
        
        self.presenter = presenter
        self.model = model
        self.childrenCoordinators = []
        self.persistence = persistence
    }

    func start() {
        let taskListViewController = TaskListViewController.instantiate()
        
        let taskListViewModel = TaskListViewModel(model: model)
        taskListViewModel.delegate = self
        
        taskListViewController.viewModel = taskListViewModel
        
        self.taskListViewController = taskListViewController
        
        presenter.pushViewController(taskListViewController, animated: true)
    }

    fileprivate func showNewTask() {
        let newTaskCoordinator = NewTaskCoordinator(isEditing: false,
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
