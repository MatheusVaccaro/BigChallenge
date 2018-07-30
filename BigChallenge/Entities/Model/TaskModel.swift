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
    
    weak var delegate: TaskModelDelegate?
    private(set) var didUpdateTasks: BehaviorSubject<[Task]>
    private(set) public var tasks: [Task]
    private let persistance: Persistence

    // MARK: - TaskModel Lifecycle
    
    init(persistence: Persistence, delegate: TaskModelDelegate? = nil) {
        self.persistance = persistence
        self.delegate = delegate
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
    
    public func save(_ task: Task) {
        guard !tasks.contains(object) else { return }
        tasks.append(object)
        persistance.save()
        didUpdateTasks.onNext(tasks)
        
        delegate?.taskModel(self, didSave: object)
    }
    
    public func delete(_ task: Task) {
        guard let taskIndex = tasks.index(of: task) else { print("could not delete \(task) "); return }
        tasks.remove(at: taskIndex)
        persistance.delete(task)
        didUpdateTasks.onNext(tasks)
        
        delegate?.taskModel(self, didDelete: object)
    }
    
    public func createTask(with attributes: [Attributes : Any]) -> Task {
        let task: Task = persistance.create(Task.self)
        
        let id = attributes[.id] as? UUID ?? UUID()
        let title = attributes[.title] as? String ?? ""
        let notes = attributes[.notes] as? String ?? ""
        let creationDate = attributes[.creationDate] as? Date ?? Date()
        let isCompleted = attributes[.isCompleted] as? Bool ?? false
        
        task.id = id
        task.title = title
        task.notes = notes
        task.creationDate = creationDate
        task.isCompleted = isCompleted
        
        if let completionDate = attributes[.completionDate] as? Date {
            task.completionDate = completionDate
        }
        
        if let dueDate = attributes[.dueDate] as? Date {
            task.dueDate = dueDate
        }
        
        delegate?.taskModel(self, didCreate: task)
        
        return task
    }
    
    public func update(_ task: Task, with attributes: [Attributes : Any]) {
        if let completionDate = attributes[.completionDate] as? Date {
            task.completionDate = completionDate
        }
        if let creationDate = attributes[.creationDate] as? Date {
            task.creationDate = creationDate
        }
        if let dueDate = attributes[.dueDate] as? Date {
            task.dueDate = dueDate
        }
        if let id = attributes[.id] as? UUID {
            task.id = id
        }
        if let isCompleted = attributes[.isCompleted] as? Bool {
            task.isCompleted = isCompleted
        }
        if let notes = attributes[.notes] as? String {
            task.notes = notes
        }
        if let title = attributes[.title] as? String {
            task.title = title
        }
    }
    
    // The attributes of the Task class, mapped according to CoreData
    public enum Attributes {
        case completionDate
        case creationDate
        case dueDate
        case id
        case isCompleted
        case notes
        case title
    }
}

protocol TaskModelDelegate: class {
    func taskModel(_ taskModel: TaskModel, didSave task: Task)
    func taskModel(_ taskModel: TaskModel, didDelete task: Task)
    func taskModel(_ taskModel: TaskModel, didCreate task: Task)
}

extension TaskModelDelegate {
    func taskModel(_ taskModel: TaskModel, didSave task: Task) { }
    func taskModel(_ taskModel: TaskModel, didDelete task: Task) { }
    func taskModel(_ taskModel: TaskModel, didCreate task: Task) { }
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

// MARK: - Imports

extension TaskModel {
    
    /**
     Associates a task to import data. Import data is determined by the import's source.
     Once a task has been associated to a import data of some type, it cannot be associated to import data of another type.
     
     - Parameters
     	- task: The task to associate import data to.
     	- importDataPacket: The import data to associate a task with.
     */
    func associateTask(_ task: Task, with importDataPacket: ImportDataPacket) {
        // Check if task has import data of the same type as importDataPacket or no data at all
        guard task.importData?.type == importDataPacket.type || task.importData == nil else { return }
        guard let taskContext = task.managedObjectContext else { return }
        
        // Initializes ImportData object
        let importDataContainer = ImportData(context: taskContext)
        task.importData = importDataContainer
        
        // Associates task with import data
        switch importDataPacket {
        case .remindersDataPacket(let id, let externalId):
            let remindersImportData = RemindersImportData(context: taskContext)

            remindersImportData.calendarItemIdentifier = id
            remindersImportData.calendarItemExternalIdentifier = externalId

            task.importData?.remindersImportData = remindersImportData
        }
    }
}
