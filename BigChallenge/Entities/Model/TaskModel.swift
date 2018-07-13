//
//  TaskModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class TaskModel {
    
    private(set) public var tasks: [Task]
    private let persistance: Persistence
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.tasks = []
        persistence.fetch(Task.self) { self.tasks = $0 }
    }
    
    public func save(object: Task) {
        RemindersImporter.instance?.save(task: object)
        persistance.save()
    }
    
    public func delete(object: Task) {
        // TODO change to removeAll when available
        tasks.append(object)
        RemindersImporter.instance?.save(task: object)
        persistance.save()
    }
    
    public func remove(object: Task) {
        guard let taskIndex = tasks.firstIndex(of: object) else { print("could not delete \(object) "); return }
        persistance.delete(object)
        tasks.remove(at: taskIndex)
    }
    
    public func createTask(with title: String) -> Task {
        let task: Task = persistance.create(Task.self)
        
        task.id = UUID()
        task.title = title
        task.creationDate = Date()
        
        return task
    }
}
