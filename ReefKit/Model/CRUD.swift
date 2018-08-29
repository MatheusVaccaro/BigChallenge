//
//  TaskCRUD.swift
//  ReefKit
//
//  Created by Bruno Fulber Wide on 23/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import Persistence

public enum TaskAttributes {
    case completionDate
    case creationDate
    case dueDate
    case id
    case isCompleted
    case notes
    case title
    case tags
    case region
    case isArriving
    case isPinned
}

public enum TagAttributes {
    case colorIndex
    case dueDate
    case id
    case title
    case tasks
    case region
    case arriving
}

class TaskCRUD {
    private let persistence: Persistence
    
    init(persistence: Persistence) {
        self.persistence = persistence
    }
    
    func fetchTasks(predicate: NSPredicate?, completionHandler: @escaping (([Task]) -> ())) {
        persistence.fetch(Task.self, predicate: predicate) {
            completionHandler($0)
        }
    }
    
    func createTask(with attributes: [TaskAttributes : Any]) -> Task {
        
        let title = attributes[.title] as? String ?? ""
        let task: Task = persistence.create(Task.self)
        let id = attributes[.id] as? UUID ?? UUID()
        let notes = attributes[.notes] as? String ?? ""
        let creationDate = attributes[.creationDate] as? Date ?? Date()
        let isCompleted = attributes[.isCompleted] as? Bool ?? false
        let tags = attributes[.tags] as? [Tag] ?? []
        let isArriving = attributes[.isArriving] as? Bool ?? true
        let isPinned = attributes[.isPinned] as? Bool ?? false
        
        task.id = id
        task.title = title
        task.notes = notes
        task.creationDate = creationDate
        task.isCompleted = isCompleted
        task.tags = NSSet(array: tags)
        task.isPinned = isPinned
        
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
            task.isArriving = isArriving
        }
        updateNotifications(for: task)
        return task
    }
    
    func update(_ task: Task, with attributes: [TaskAttributes : Any]) {
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
        if let tags = attributes[.tags] as? [Tag] {
            task.tags = NSSet(array: tags)
            NotificationManager.addAllTagsNotifications(from: task.allTags)
        }
        
        if let region = attributes[.region] as? CLCircularRegion {
            let regionData =
                NSKeyedArchiver.archivedData(withRootObject: region)
            task.regionData = regionData
            task.isArriving = attributes[.isArriving] as? Bool ?? true
        }
        
        if let isPinned = attributes[.isPinned] as? Bool {
            task.isPinned = isPinned
        }
        
        updateNotifications(for: task)
    }
    
    func save(_ task: Task) {
        persistence.save()
    }
    
    func delete(_ task: Task) {
        NotificationManager.removeLocationNotification(for: task)
        NotificationManager.removeDateNotification(for: task)
        NotificationManager.removeAllTagsNotifications(for: task)
        persistence.delete(task)
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

public class TagCRUD {
    private var currentColor: Int = 0 //TODO: save to user defaults

    private func nextColor() -> Int64 {
        currentColor += 1
        return Int64( currentColor % UIColor.tagColors.count )
    }
    
    private let persistence: Persistence
    
    init(persistence: Persistence) {
        self.persistence = persistence
    }
    
    func fetchTags(predicate: NSPredicate?, completionHandler: @escaping (([Tag]) -> ())) {
        persistence.fetch(Tag.self, predicate: predicate) {
            completionHandler($0)
        }
    }
    
    func createTag(with attributes: [TagAttributes : Any]) -> Tag {
        
        let title = attributes[.title] as? String
        let tag = persistence.create(Tag.self)
        let colorIndex = attributes[.colorIndex] as? Int64 ?? nextColor()
        let id = attributes[.id] as? UUID ?? UUID()
        let tasks = attributes[.tasks] as? [Task] ?? []
        let arriving = attributes[.arriving] as? Bool ?? false
        
        tag.colorIndex = colorIndex
        tag.id = id
        tag.title = title
        tag.tasks = NSSet(array: tasks)
        
        if let dueDate = attributes[.dueDate] as? Date {
            tag.dueDate = dueDate
        }
        if let region = attributes[.region] as? CLCircularRegion {
            let regionData =
                NSKeyedArchiver.archivedData(withRootObject: region)
            tag.regionData = regionData
            tag.arriving = arriving
        }
        
        return tag
    }
    
    func update(_ tag: Tag, with attributes: [TagAttributes: Any]) {
        if let color = attributes[.colorIndex] as? Int64 {
            tag.colorIndex = color
        }
        if let dueDate = attributes[.dueDate] as? Date {
            tag.dueDate = dueDate
        }
        if let id = attributes[.id] as? UUID {
            tag.id = id
        }
        if let title = attributes[.title] as? String {
            tag.title = title
        }
        if let tasks = attributes[.tasks] as? [Task] {
            tag.tasks = NSSet(array: tasks)
        }
        if let colorIndex = attributes[.colorIndex] as? Int64 {
            tag.colorIndex = colorIndex
        }
        if let arriving = attributes[.arriving] as? Bool {
            tag.arriving = arriving
        }
        if let region = attributes[.region] as? CLCircularRegion {
            let regionData = NSKeyedArchiver.archivedData(withRootObject: region)
            tag.regionData = regionData
        }
    }
    
    func delete(_ tag: Tag) {
        persistence.delete(tag)
    }
    
    func save(_ tag: Tag) {
        //TODO: do more stuff
        persistence.save()
    }
}
