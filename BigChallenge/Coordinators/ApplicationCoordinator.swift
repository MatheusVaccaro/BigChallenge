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
    private let persistence: Persistence
    private let reefKit: ReefKit
    private let taskModel: TaskModel
    private let tagModel: TagModel
    private var selectedTags: [Tag]
    
    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()
        self.rootViewController.isNavigationBarHidden = true
        self.childrenCoordinators = []
        self.reefKit = ReefKit()
        self.persistence = reefKit.persistence
        self.tagModel = TagModel(reefKit: reefKit)
        self.taskModel = TaskModel(reefKit: reefKit)
        self.selectedTags = []
        print(selectedTags.map { $0.title! })
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
        startFabric()
        UITextField.appearance().keyboardAppearance = .light
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
                                                        selectedTags: selectedTags)
        addChild(coordinator: homeScreenCoordinator)
        homeScreenCoordinator.start()
    }
}
