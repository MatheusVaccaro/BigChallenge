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
    
    private let persistence: Persistence
    private let window: UIWindow
    private let rootViewController: UINavigationController
    var childrenCoordinators: [Coordinator]
    
    
    init(window: UIWindow) {
        // TODO logic to select correct persistence implementation
        self.persistence = MockPersistence()
        
        self.window = window
        self.rootViewController = UINavigationController()
        self.rootViewController.navigationBar.prefersLargeTitles = true
        self.childrenCoordinators = []
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        showTaskList()
    }
    
    private func showTaskList() {
        let taskListCoordinator = TaskListCoordinator(presenter: rootViewController, persistence: persistence)
        addChild(coordinator: taskListCoordinator)
        taskListCoordinator.start()
    }
}
