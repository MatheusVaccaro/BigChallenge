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
    
    var didUpdateTasks: (([Task]) -> Void)?
    
    private(set) public var tasks: [Task]
    private let persistance: Persistence
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.tasks = []
        
        persistence.fetch(Task.self) {
            tasks = $0
        }
        
        persistence.didAddTasks = {
            for task in $0 { //filter tasks added by this device
                guard !self.tasks.contains(task) else { continue }
                self.tasks.append(task)
            }
            self.didUpdateTasks?(self.tasks)
        }
    }
    
    public func update() {
        persistance.save()
    }
    
    public func save(object: Task) {
        guard !tasks.contains(object) else { return }
        tasks.append(object)
        RemindersImporter.instance?.save(task: object)
        persistance.save()
    }
    
    public func delete(object: Task) {
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
