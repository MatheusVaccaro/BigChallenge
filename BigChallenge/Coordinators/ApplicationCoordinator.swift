//
//  ApplicationCoordinator.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 23/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import Fabric
import Crashlytics

class ApplicationCoordinator: Coordinator {
    
    public var childrenCoordinators: [Coordinator]
    private let window: UIWindow
    private let rootViewController: UINavigationController
    private let persistence: Persistence
    private let taskModel: TaskModel
    private let tagModel: TagModel
    private let selectedTags: [Tag]
    
    init(window: UIWindow, selectedTagIDs: [String]) {
        self.window = window
        self.rootViewController = UINavigationController()
        self.rootViewController.isNavigationBarHidden = true
        self.childrenCoordinators = []
        self.persistence = Persistence(configuration: .inDevice)
        self.tagModel = TagModel(persistence: persistence)
        self.taskModel = TaskModel(persistence: persistence)
        self.selectedTags =
            tagModel.tags.filter { selectedTagIDs.contains($0.id!.description) }
        print(selectedTags.map { $0.title! })
    }
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        showTaskList()
        UITextField.appearance().keyboardAppearance = .light
        startFabric()
    }
    
    private func startFabric() {
        Fabric.with([Crashlytics.self])
    }
    
    private func showTaskList() {
        let homeScreenCoordinator = HomeScreenCoordinator(presenter: rootViewController,
                                                        taskModel: taskModel,
                                                        tagModel: tagModel,
                                                        persistence: persistence,
                                                        selectedTags: selectedTags)
        addChild(coordinator: homeScreenCoordinator)
        homeScreenCoordinator.start()
    }
}
