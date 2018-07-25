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
    
    // MARK: - Properties
    
    private(set) var didUpdateTasks: BehaviorSubject<[Task]>
    private(set) public var tasks: [Task]
    private let persistance: Persistence

    // MARK: - TaskModel Lifecycle
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.tasks = []
        self.didUpdateTasks = BehaviorSubject<[Task]>(value: tasks)
        
        persistance.tasksDelegate = self
        persistence.fetch(Task.self) {
            tasks = $0
        }
        didUpdateTasks.onNext(tasks)
    }
    
    // MARK: - CRUD Methods
    
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
    
    public func update(_ task: Task, with dictionary: [Attributes : Any]) {
        if let completionDate = dictionary[.completionDate] as? Date {
            task.completionDate = completionDate
        }
        if let creationDate = dictionary[.creationDate] as? Date {
            task.creationDate = creationDate
        }
        if let dates = dictionary[.dates] as? [Date] {
            task.dates = dates
        }
        if let dueDate = dictionary[.dueDate] as? Date {
            task.dueDate = dueDate
        }
        if let id = dictionary[.id] as? UUID {
            task.id = id
        }
        if let isCompleted = dictionary[.isCompleted] as? Bool {
            task.isCompleted = isCompleted
        }
        if let notes = dictionary[.notes] as? String {
            task.notes = notes
        }
        if let title = dictionary[.title] as? String {
            task.title = title
        }
    }
    
    // The attributes of the Task class, mapped according to CoreData
    public enum Attributes {
        case completionDate
        case creationDate
        case dates
        case dueDate
        case id
        case isCompleted
        case notes
        case title
    }
}

// MARK: - TaskPersistenceDelegate Extension

extension TaskModel: TasksPersistenceDelegate {
    
    func persistence(_ persistence: Persistence, didInsertTasks tasks: [Task]) {
        for task in tasks {
            guard !self.tasks.contains(task) else { continue }
            self.tasks.append(task)
        }
        self.didUpdateTasks.onNext(self.tasks)
    }
    
    func persistence(_ persistence: Persistence, didUpdateTasks tasks: [Task]) {
        for task in tasks {
            guard let index = self.tasks.index(of: task) else { continue }
            self.tasks[index] = task
        }
        self.didUpdateTasks.onNext(self.tasks)
    }
    
    func persistence(_ persistence: Persistence, didDeleteTasks tasks: [Task]) {
        for task in tasks {
            guard let index = self.tasks.index(of: task) else { continue }
            self.tasks.remove(at: index)
        }
        self.didUpdateTasks.onNext(self.tasks)
    }
}
