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

class Recommender {
    
    init(model: TaskModel) {
        self.model = model
        self.locationManager = LocationManager()
        subscribeToModel()
    }
    
    // MARK: - Recommendation
    fileprivate var model: TaskModel
    fileprivate var _recommendedTasks: [Task]?
    fileprivate var tasks: [Task] {
        return model.tasks
    }
    fileprivate let locationManager: LocationManager
    fileprivate let disposeBag = DisposeBag()
    
    func reset() {
        _recommendedTasks = nil
    }
    
    var recommendedTasks: [Task] {
        guard _recommendedTasks == nil else { return _recommendedTasks! }
        
        var pinnedTasks: [Task] = []
        var localTasks: [Task] = []; let localTasksLimit = 3
        var nextTasks: [Task] = []; let nextTasksLimit = 2
        var latestTasks: [Task] = []; let latestTasksLimit = 1
        
        var toDo = tasks
            .filter { !$0.isCompleted }
        
        toDo = toDo.filter {
            if $0.isPinned { pinnedTasks.append($0); return false }
            return true
        }
        
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
    
    fileprivate func subscribeToModel() {
        model.didUpdateTasks.subscribe {
            for task in $0.element! {
                if let tasks = self._recommendedTasks, task.isCompleted, let index = tasks.index(of: task) {
                    self._recommendedTasks?.remove(at: index)
                }
            }
            }.disposed(by: disposeBag)
    }
}
