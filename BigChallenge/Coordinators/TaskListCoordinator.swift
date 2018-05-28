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
    
    fileprivate let presenter: UINavigationController
    fileprivate var taskListViewController: TaskListViewController?
    var childrenCoordinators: [Coordinator]
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
        self.childrenCoordinators = []
    }
    
    func start() {
        let taskListViewController = TaskListViewController.instantiate()
        self.taskListViewController = taskListViewController
        
        let taskListViewModel = TaskListViewModel(persistence: MockPersistence())
        taskListViewModel.delegate = self
        taskListViewController.viewModel = taskListViewModel
        
        presenter.pushViewController(taskListViewController, animated: true)
    }

    fileprivate func showNewTask() {
        let newTaskCoordinator = NewTaskCoordinator(task: Task(), isEditing: false, presenter: presenter)
        newTaskCoordinator.delegate = self
        addChild(coordinator: newTaskCoordinator)
        newTaskCoordinator.start()
    }
    
    fileprivate func showEditTask(_ task: Task) {
        let newTaskCoordinator = NewTaskCoordinator(task: task, isEditing: true, presenter: presenter)
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
