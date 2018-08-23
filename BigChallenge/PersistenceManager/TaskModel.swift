//
//  TaskModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import ReefKit

public class TaskModel {
    // MARK: - Properties
    
    weak var delegate: TaskModelDelegate?
    private(set) var didUpdateTasks: BehaviorSubject<[Task]>
    private(set) public var tasks: [Task]
    private let reefKit: ReefKit

    // MARK: - TaskModel Lifecycle
    
    init(reefKit: ReefKit, delegate: TaskModelDelegate? = nil) {
        self.reefKit = reefKit
        self.delegate = delegate
        self.tasks = []
        self.didUpdateTasks = BehaviorSubject<[Task]>(value: tasks)
        reefKit.persistence.tasksDelegate = self
        
        reefKit.persistence.fetch(Task.self) {
            tasks = $0
        }
        didUpdateTasks.onNext(tasks)
    }
    
    // MARK: - CRUD Methods
    public func save(_ task: Task) {
        if !tasks.contains(task) { tasks.append(task) }
        reefKit.persistence.save()
    }
    
    public func delete(_ task: Task) {
        guard tasks.contains(task) else { print("could not delete \(task) "); return }
        ReefSpotlight.deindex(task: task) // TODO: move to reefSpotlghtKit
        NotificationManager.removeLocationNotification(for: task) // TODO: move to notificationKit
        NotificationManager.removeDateNotification(for: task)
        reefKit.persistence.delete(task)
    }
    
    public func createTask(with attributes: [TaskAttributes : Any]) -> Task {
        let task = reefKit.createTask(with: attributes)! //TODO: remove force cast
        updateNotifications(for: task)
        delegate?.taskModel(self, didCreate: task)
        if !task.isCompleted { ReefSpotlight.index(task: task) }
        if let tags = task.tags?.allObjects as? [Tag] {
            NotificationManager.addAllTagsNotifications(from: tags)
        }
        return task
    }
    
    public func update(_ task: Task, with attributes: [TaskAttributes : Any]) {
        reefKit.update(task, with: attributes)
        updateNotifications(for: task)
        ReefSpotlight.updateInSpotlight(task: task)
    }
    
    func taskWith(id: UUID) -> Task? {
        return tasks.first { $0.id! == id }
    }
    
    fileprivate func updateNotifications(for task: Task) {
        if task.isCompleted {
            NotificationManager.removeLocationNotification(for: task)
            NotificationManager.removeDateNotification(for: task)
        } else {
            NotificationManager.addLocationNotification(for: task)
            NotificationManager.addDateNotification(for: task)
        }
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
    
    public func persistence(_ persistence: Persistence, didInsertTasks tasks: [Task]) {
        for task in tasks {
            guard !self.tasks.contains(task) else { continue }
            self.tasks.append(task)
        }
        self.didUpdateTasks.onNext(self.tasks)
    }
    
    public func persistence(_ persistence: Persistence, didUpdateTasks tasks: [Task]) {
        for task in tasks {
            guard let index = self.tasks.index(of: task) else { continue }
            self.tasks[index] = task
        }
        self.didUpdateTasks.onNext(self.tasks)
    }
    
    public func persistence(_ persistence: Persistence, didDeleteTasks tasks: [Task]) {
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
    func associate(_ task: Task, with importDataPacket: ImportDataPacket) {
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
