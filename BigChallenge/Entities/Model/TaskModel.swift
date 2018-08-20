//
//  TaskModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import CoreSpotlight
import MobileCoreServices
import RxCocoa
import RxSwift

public class TaskModel {
    
    static func regions(of task: Task) -> [CLCircularRegion] {
        var ans: [CLCircularRegion] = []
        
        //data is stored in task
        if let data =
            task.regionData { ans.append(NSKeyedUnarchiver.unarchiveObject(with: data) as! CLCircularRegion) }
        
        // OR
        //data is stored in one of its tags
        
        let tagsData = task.allTags
            .map { $0.regionData }
        
        for data in tagsData where data != nil {
            ans.append(NSKeyedUnarchiver.unarchiveObject(with: data!) as! CLCircularRegion)
        }
        
        return ans
    }
    
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
    public func save(_ task: Task) {
        if !tasks.contains(task) { tasks.append(task) }
        persistance.save() // delegate manages the array
    }
    
    public func delete(_ task: Task) {
        guard tasks.contains(task) else { print("could not delete \(task) "); return }
        deindex(task: task)
        NotificationManager.removeLocationNotification(for: task)
        NotificationManager.removeDateNotification(for: task)
        persistance.delete(task) // delegate manages the array
    }
    
    public func createTask(with attributes: [Attributes : Any]) -> Task {
        let task: Task = persistance.create(Task.self)
        
        let id = attributes[.id] as? UUID ?? UUID()
        let title = attributes[.title] as? String ?? ""
        let notes = attributes[.notes] as? String ?? ""
        let creationDate = attributes[.creationDate] as? Date ?? Date()
        let isCompleted = attributes[.isCompleted] as? Bool ?? false
        let tags = attributes[.tags] as? [Tag] ?? []
        let arriving = attributes[.arriving] as? Bool ?? true
        
        task.id = id
        task.title = title
        task.notes = notes
        task.creationDate = creationDate
        task.isCompleted = isCompleted
        task.tags = NSSet(array: tags)
        
        if let completionDate = attributes[.completionDate] as? Date {
            task.completionDate = completionDate
        }
        if let dueDate = attributes[.dueDate] as? Date {
            task.dueDate = dueDate
        }
        if let region = attributes[.region] as? CLCircularRegion {
            let regionData =
                NSKeyedArchiver.archivedData(withRootObject: region)
            task.regionData = regionData
            task.arriving = arriving
        }
        updateNotifications(for: task)
        delegate?.taskModel(self, didCreate: task)
        if let tags = task.tags?.allObjects as? [Tag] {
            NotificationManager.addAllTagsNotifications(from: tags)
        }
        
        if !isCompleted { index(task: task) }
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
            updateNotifications(for: task)
        }
        if let notes = attributes[.notes] as? String {
            task.notes = notes
        }
        if let title = attributes[.title] as? String {
            task.title = title
        }
        if let tags = attributes[.tags] as? [Tag] {
            task.tags = NSSet(array: tags)
        }
        
        if let region = attributes[.region] as? CLCircularRegion {
            let regionData =
                NSKeyedArchiver.archivedData(withRootObject: region)
            task.regionData = regionData
            task.arriving = attributes[.arriving] as? Bool ?? true
        }
        
        updateInSpotlight(task: task)
        persistance.save()
        delegate?.taskModel(self, didUpdate: task, with: attributes)
    }
    
    func taskWith(id: UUID) -> Task? {
        return tasks.first { $0.id! == id }
    }
    
    private func index(task: Task) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        attributeSet.title = task.title!
        attributeSet.contentDescription = task.notes
        
        attributeSet.contentCreationDate = task.creationDate
        
        let item = CSSearchableItem(uniqueIdentifier: "task-\(task.id!)",
            domainIdentifier: "com.beanie",
            attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateInSpotlight(task: Task) {
        deindex(task: task)
        index(task: task)
    }
    
    func deindex(task: Task) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(task.id!)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            }
        }
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
    
    // The attributes of the Task class, mapped according to CoreData
    public enum Attributes {
        case completionDate
        case creationDate
        case dueDate
        case id
        case isCompleted
        case notes
        case title
        case tags
        case region
        case arriving
    }
}

protocol TaskModelDelegate: class {
    func taskModel(_ taskModel: TaskModel, didSave task: Task)
    func taskModel(_ taskModel: TaskModel, didDelete task: Task)
    func taskModel(_ taskModel: TaskModel, didCreate task: Task)
    func taskModel(_ taskModel: TaskModel, didUpdate task: Task, with attributes: [TaskModel.Attributes: Any])
}

extension TaskModelDelegate {
    func taskModel(_ taskModel: TaskModel, didSave task: Task) { }
    func taskModel(_ taskModel: TaskModel, didDelete task: Task) { }
    func taskModel(_ taskModel: TaskModel, didCreate task: Task) { }
    func taskModel(_ taskModel: TaskModel, didUpdate task: Task, with attributes: [TaskModel.Attributes: Any]) { }
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
