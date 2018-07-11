//
//  ApplicationCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 23/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

class ApplicationCoordinator: Coordinator {
    
    public var childrenCoordinators: [Coordinator]
    private let window: UIWindow
    private let rootViewController: UINavigationController
    private let persistence: Persistence
    private let taskModel: TaskModel
    private let tagModel: TagModel
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()
        self.rootViewController.navigationBar.prefersLargeTitles = true
        self.childrenCoordinators = []
        self.persistence = Persistence()
        self.taskModel = TaskModel(persistence: persistence)
        self.tagModel = TagModel(persistence: persistence)
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        showTaskList()
        RemindersImporter.instantiate(taskModel: taskModel, tagModel: tagModel)
    }
    
    private func showTaskList() {
        let taskListCoordinator = TaskListCoordinator(presenter: rootViewController,
                                                      model: taskModel,
                                                      persistence: persistence)
        addChild(coordinator: taskListCoordinator)
        taskListCoordinator.start()
    }
}
