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
import ReefKit

class ApplicationCoordinator: Coordinator {
    public var childrenCoordinators: [Coordinator]
    private let window: UIWindow
    private let rootViewController: UINavigationController
    private let reefKit: ReefKit
    private let taskModel: TaskModel
    private let tagModel: TagModel
    private let remindersImporter: RemindersImporter
    private var selectedTags: [Tag]
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()
        self.childrenCoordinators = []
        self.reefKit = ReefKit()
        self.tagModel = TagModel(reefKit: reefKit)
        self.taskModel = TaskModel(reefKit: reefKit)
        self.remindersImporter = RemindersImporter(taskModel: taskModel, tagModel: tagModel)
        self.selectedTags = []
        
        configureNavigationController()
    }
    
    private func configureNavigationController() {
        rootViewController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        rootViewController.navigationBar.shadowImage = UIImage()
        rootViewController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationBar.isTranslucent = true
        rootViewController.view.backgroundColor = .clear
        rootViewController.navigationBar.largeTitleTextAttributes = largeTitleAttributes
    }
    
    func refreshModel() { //TODO: find a better solution
        reefKit.refresh()
        taskModel.loadTasks()
    }
    
    func start() {
        self.start(selectedTagIDs: nil, taskID: nil)
    }
    
    func start(selectedTagIDs: [String]? = nil, taskID: String? = nil) {
        if let selectedTagIDs = selectedTagIDs {
            selectedTags =
                tagModel.tags.filter { selectedTagIDs.contains($0.id!.description) }
        } else if let taskID = taskID {
            selectedTags =
                taskModel.taskWith(id: UUID(uuidString: taskID)!)!.allTags
        }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        showTaskList()
        #if RELEASE
        startFabric()
        #endif
    }
    
    private func startFabric() {
        Fabric.with([Crashlytics.self])
        Answers.logCustomEvent(withName: "started app",
                               customAttributes: ["fontSize":UIApplication.shared.preferredContentSizeCategory,
                                                  "isVoiceOverOn":UIAccessibility.isVoiceOverRunning,
                                                  "hasInvertedColors":UIAccessibility.isInvertColorsEnabled])
    }
    
    private func showTaskList() {
        let homeScreenCoordinator = HomeScreenCoordinator(presenter: rootViewController,
                                                        taskModel: taskModel,
                                                        tagModel: tagModel,
                                                        selectedTags: selectedTags,
                                                        remindersImporter: remindersImporter)
        addChild(coordinator: homeScreenCoordinator)
        homeScreenCoordinator.start()
    }
}
