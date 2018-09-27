//
//  Recommender.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

public class Recommender {
    
    private(set) var pinnedTasks: [Task] = []
    private(set) public var lateTasks: [Task] = []; let lateTasksLimit = 3
    private(set) public var localTasks: [Task] = []; let localTasksLimit = 3
    private(set) public var nextTasks: [Task] = []; let nextTasksLimit = 2
    private(set) public var recentTasks: [Task] = []; let recentTasksLimit = 1
    
    let locationManager = LocationManager()
    
    public var all: [Task] {
        return pinnedTasks + lateTasks + localTasks + nextTasks + recentTasks
    }
    
    public init(tasks: [Task]) {
        var toDo = tasks
            .filter { !$0.isCompleted && !$0.isPrivate }
        
        toDo = toDo.filter {
            if $0.isPinned { pinnedTasks.append($0); return false }
            return true
        }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            if let location = locationManager.currentLocation {
                localTasks = Array(
                    toDo
                        .filter { $0.isInside(location) }
                        .prefix(localTasksLimit)
                )
                toDo = toDo
                    .filter { !localTasks.contains($0) }
            }
        }
        
        lateTasks = Array(
            toDo
                .filter { $0.dueDate != nil }
                .filter { $0.dueDate!.timeIntervalSinceNow < 0 }
                .sorted { $1.isBefore($0) }
                .prefix(lateTasksLimit)
        )
        
        nextTasks = Array(
            toDo
                .filter { !$0.dates.isEmpty }
                .sorted { $0.isBefore($1) }
                .prefix(nextTasksLimit)
        )
        
        recentTasks = Array(
            toDo
                .filter { return !nextTasks.contains($0) && $0.creationDate!.timeIntervalSinceNow > -129600 }
                .sorted { $0.creationDate! > $1.creationDate! }
                .prefix(recentTasksLimit)
        )
    }
}
