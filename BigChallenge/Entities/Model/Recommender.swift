//
//  Recommender.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

class Recommender {
    
    init(model: TaskModel) {
        self.model = model
        self.locationManager = LocationManager()
    }
    
    // MARK: - Recommendation
    fileprivate var model: TaskModel
    fileprivate var _recommendedTasks: [Task]?
    fileprivate var tasks: [Task] {
        return model.tasks
    }
    fileprivate let locationManager: LocationManager
    
    var recommendedTasks: [Task] {
        guard _recommendedTasks == nil else { return _recommendedTasks! }
        
        var latestTasks: [Task] = []; let latestTasksLimit = 1
        var localTasks: [Task] = []; let localTasksLimit = 2
        var nextTasks: [Task] = []; let nextTasksLimit = 3
        
        var toDo = tasks
            .filter { !$0.isCompleted }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            if let location = locationManager.currentLocation {
                localTasks = Array(
                    tasks
                        .filter { $0.isInside(location) }
                        .prefix(localTasksLimit)
                )
                toDo = toDo
                    .filter { !localTasks.contains($0) }
            }
        }
        
        nextTasks = Array(
            toDo
                .filter { $0.dueDate != nil }
                .sorted { $0.isBefore($1) }
                .prefix(nextTasksLimit)
        )
        
        latestTasks = Array(
            toDo
                .filter { !nextTasks.contains($0) }
                .sorted { $0.creationDate! > $1.creationDate! }
                .prefix(latestTasksLimit)
        )
        
        _recommendedTasks = latestTasks + nextTasks + localTasks
        return _recommendedTasks!
    }
}
