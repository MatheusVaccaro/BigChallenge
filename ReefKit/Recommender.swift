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
    // MARK: - Recommendation
    fileprivate static var _recommendedTasks: [Task]?
    
    
    public static func recommended(from tasks: [Task]) -> [Task] {
        guard _recommendedTasks == nil else { return _recommendedTasks! }
        
        var pinnedTasks: [Task] = []
        var localTasks: [Task] = []; let localTasksLimit = 3
        var nextTasks: [Task] = []; let nextTasksLimit = 2
        var latestTasks: [Task] = []; let latestTasksLimit = 1
        let locationManager = LocationManager()
        
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
        
        nextTasks = Array(
            toDo
                .filter { !$0.dates.isEmpty }
                .sorted { $0.isBefore($1) }
                .prefix(nextTasksLimit)
        )
        
        latestTasks = Array(
            toDo
                .filter {
                    print($0.creationDate!.timeIntervalSinceNow)
                    print($0.title!)
                    return !nextTasks.contains($0) && $0.creationDate!.timeIntervalSinceNow > -129600 }
                .sorted { $0.creationDate! > $1.creationDate! }
                .prefix(latestTasksLimit)
        )
        
        _recommendedTasks = latestTasks + nextTasks + localTasks
        return _recommendedTasks!
    }
    
    public static func reset() { _recommendedTasks = nil }
}
