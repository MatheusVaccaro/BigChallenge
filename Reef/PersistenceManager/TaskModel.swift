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

protocol TaskModelDelegate: class {
    func taskModel(_ taskModel: TaskModel, didInsert tasks: [Task])
    func taskModel(_ taskModel: TaskModel, didDelete tasks: [Task])
    func taskModel(_ taskModel: TaskModel, didUpdate tasks: [Task])
}

public class TaskModel {
    // MARK: - Properties
    
    weak var delegate: TaskModelDelegate?
    
    private(set) public var tasks: [Task]
    private(set) public var recommender: Recommender
    private let reefKit: ReefKit

    init(reefKit: ReefKit) {
        self.reefKit = reefKit
        self.tasks = []
        recommender = Recommender(tasks: tasks)
        
        reefKit.tasksDelegate = self
        
        loadTasks()
    }
    
    func loadTasks() {
        reefKit.fetchTasks {
            self.tasks = $0
            self.recommender = Recommender(tasks: $0)
        }
    }
    
    // MARK: - CRUD Methods
    public func save(_ task: Task) {
        reefKit.save(task)
    }
    
    public func delete(_ task: Task) {
        guard tasks.contains(task) else { print("could not delete \(task) "); return }
        reefKit.delete(task)
    }
    
    public func createTask(with attributes: [TaskAttributes : Any]) -> Task {
        let task = reefKit.createTask(with: attributes)
        return task
    }
    
    public func update(_ task: Task, with attributes: [TaskAttributes : Any]) {
        reefKit.update(task, with: attributes)
    }
    
    func taskWith(id: UUID) -> Task? {
        return tasks.first { $0.id! == id }
    }
}

// MARK: - TaskPersistenceDelegate Extension

extension TaskModel: ReefTaskDelegate {
    public func reef(_ reefKit: ReefKit, didInsertTasks tasks: [Task]) {
        for task in tasks {
            guard !self.tasks.contains(task) else { continue }
            self.tasks.append(task)
        }
        recommender = Recommender(tasks: self.tasks)
        delegate?.taskModel(self, didInsert: tasks)
    }
    
    public func reef(_ reefKit: ReefKit, didUpdateTasks tasks: [Task]) {
//        for task in tasks {
//            if let index = self.tasks.index(of: task) { self.tasks[index] = task }
//        } TODO: review this 
        recommender = Recommender(tasks: self.tasks)
        delegate?.taskModel(self, didUpdate: tasks)
    }
    
    public func reef(_ reefKit: ReefKit, didDeleteTasks tasks: [Task]) {
        for task in tasks {
            if let index = self.tasks.index(of: task) { _ = self.tasks.remove(at: index) }
        }
        recommender = Recommender(tasks: self.tasks)
        delegate?.taskModel(self, didDelete: tasks)
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
