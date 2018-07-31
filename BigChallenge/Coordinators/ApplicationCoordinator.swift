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
    private let remindersImporter: RemindersImporter
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()
        self.rootViewController.isNavigationBarHidden = true
        self.childrenCoordinators = []
        
        self.persistence = Persistence(configuration: .inDevice)
        self.tagModel = TagModel(persistence: persistence)
        
        self.taskModel = TaskModel(persistence: persistence)
        defer { self.taskModel.delegate = self }
        
        self.remindersImporter = RemindersImporter(taskModel: taskModel, tagModel: tagModel)
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        showTaskList()
        remindersImporter.attemptToImport()
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
        remindersImporter.exportTaskToReminders(task)
    }
}
