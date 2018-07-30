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
        self.rootViewController.isNavigationBarHidden = true
        self.childrenCoordinators = []
        
        self.persistence = Persistence(configuration: .inDevice)
        self.tagModel = TagModel(persistence: persistence)
        
        self.taskModel = TaskModel(persistence: persistence)
        self.taskModel.delegate = self
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        showTaskList()
        RemindersImporter.instantiate(taskModel: taskModel, tagModel: tagModel)
        RemindersImporter.instance?.attemptToImport()
    }
    
    private func showTaskList() {
        let homeScreenCoordinator = HomeScreenCoordinator(presenter: rootViewController,
                                                        taskModel: taskModel,
                                                        tagModel: tagModel,
                                                        persistence: persistence)
        addChild(coordinator: homeScreenCoordinator)
        homeScreenCoordinator.start()
    }
}

extension ApplicationCoordinator: TaskModelDelegate {
    func taskModel(_ taskModel: TaskModel, didSave task: Task) {
        RemindersImporter.instance?.exportTaskToReminders(task)
    }
}
