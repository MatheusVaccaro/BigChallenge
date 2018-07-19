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
    
    private(set) var didUpdateTasks: BehaviorSubject<[Task]>
    private(set) public var tasks: [Task]
    private let persistance: Persistence
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.tasks = []
        self.didUpdateTasks = BehaviorSubject<[Task]>(value: tasks)
        
        persistence.fetch(Task.self) {
            tasks = $0
        }
        
        persistence.didAddTasks = {
            for task in $0 { //filter tasks added by this device
                guard !self.tasks.contains(task) else { continue }
                self.tasks.append(task)
            }
            self.didUpdateTasks.onNext(self.tasks)
        }
        didUpdateTasks.onNext(tasks)
    }
    
    public func saveContext() {
        persistance.save()
    }
    
    public func save(object: Task) {
        guard !tasks.contains(object) else { return }
        tasks.append(object)
        RemindersImporter.instance?.save(task: object)
        persistance.save()
        didUpdateTasks.onNext(tasks)
    }
    
    public func delete(object: Task) {
        guard let taskIndex = tasks.index(of: object) else { print("could not delete \(object) "); return }
        persistance.delete(object)
        tasks.remove(at: taskIndex)
        didUpdateTasks.onNext(tasks)
    }
    
    public func createTask(with title: String) -> Task {
        let task: Task = persistance.create(Task.self)
        
        task.id = UUID()
        task.title = title
        task.creationDate = Date()
        
        return task
    }
}
