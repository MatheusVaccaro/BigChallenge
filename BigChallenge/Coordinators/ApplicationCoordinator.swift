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
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()
        self.rootViewController.navigationBar.prefersLargeTitles = true
        self.childrenCoordinators = []
        self.persistence = Persistence()
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        showTaskList()
    }
    
    private func showTaskList() {
        let taskListCoordinator = TaskListCoordinator(presenter: rootViewController,
                                                      model: TaskModel(persistence: persistence),
                                                      persistence: persistence)
        addChild(coordinator: taskListCoordinator)
        taskListCoordinator.start()
    }
}
