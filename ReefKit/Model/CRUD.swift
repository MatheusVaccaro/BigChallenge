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

public typealias TaskInformation = [TaskAttributes: Any]
public enum TaskAttributes {
    case completionDate
    case creationDate
    case dueDate
    case id
    case isCompleted
    case notes
    case title
    case tags
    case location
    case isArrivingLocation
    case locationName
    case isPinned
}

public typealias TagInformation = [TagAttributes: Any]
public enum TagAttributes {
    case colorIndex
    case dueDate
    case id
    case title
    case tasks
    case location
    case isArrivingLocation
    case locationName
    case requiresAuthentication
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
    
    func createTask(with information: TaskInformation) -> Task {
        let title = information[.title] as? String ?? ""
        let task: Task = persistence.create(Task.self)
        let id = information[.id] as? UUID ?? UUID()
        let notes = information[.notes] as? String ?? ""
        let creationDate = information[.creationDate] as? Date ?? Date()
        let isCompleted = information[.isCompleted] as? Bool ?? false
        let tags = information[.tags] as? [Tag] ?? []
        let isArriving = information[.isArrivingLocation] as? Bool ?? true
        let isPinned = information[.isPinned] as? Bool ?? false
        
        task.id = id
        task.title = title
        task.notes = notes
        task.creationDate = creationDate
        task.isCompleted = isCompleted
        task.tags = NSSet(array: tags)
        task.isPinned = isPinned
        
        if let completionDate = information[.completionDate] as? Date {
            task.completionDate = completionDate
        }
        if let dueDate = information[.dueDate] as? Date {
            task.dueDate = dueDate
        }
        if let region = information[.location] as? CLCircularRegion {
            let regionData =
                NSKeyedArchiver.archivedData(withRootObject: region)
            let placeName = information[.locationName] as! String
            
            task.locationData = regionData
            task.isArrivingLocation = isArriving
            task.locationName = placeName
        }
        updateNotifications(for: task)
        NotificationManager.addAllTagsNotifications(from: task.allTags)
        return task
    }
    
    func update(_ task: Task, with taskInformation: TaskInformation) {
        if let completionDate = taskInformation[.completionDate] as? Date {
            task.completionDate = completionDate
        }
        if let creationDate = taskInformation[.creationDate] as? Date {
            task.creationDate = creationDate
        }
        if let dueDate = taskInformation[.dueDate] as? Date? {
            task.dueDate = dueDate
        }
        if let id = taskInformation[.id] as? UUID {
            task.id = id
        }
        if let isCompleted = taskInformation[.isCompleted] as? Bool {
            task.isCompleted = isCompleted
            if isCompleted {
                NotificationManager.removeLocationNotification(for: task)
                NotificationManager.removeDateNotification(for: task)
                NotificationManager.removeAllTagsNotifications(for: task)
            }
        }
        if let notes = taskInformation[.notes] as? String {
            task.notes = notes
        }
        if let title = taskInformation[.title] as? String {
            task.title = title
        }
        if let tags = taskInformation[.tags] as? [Tag] {
            task.tags = NSSet(array: tags)
            NotificationManager.addAllTagsNotifications(from: task.allTags)
        }
        
        if let region = taskInformation[.location] as? CLCircularRegion {
            let regionData =
                NSKeyedArchiver.archivedData(withRootObject: region)
            if let placeName = taskInformation[.locationName] as? String { task.locationName = placeName }
            if let isArriving = taskInformation[.isArrivingLocation] as? Bool { task.isArrivingLocation = isArriving }
            task.locationData = regionData
        } else {
            task.locationData = nil
        }
        
        if let isPinned = taskInformation[.isPinned] as? Bool {
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
    private var currentColor: Int = -1 //TODO: save to user defaults
    
    private var numberOfColors = UIColor.tagColors.count
    
    var nextColor: Int64 {
        currentColor += 1
        if currentColor >= numberOfColors {
            currentColor = 0
        }
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
    
    func createTag(with information: TagInformation) -> Tag {
        
        let title = information[.title] as? String
        let tag = persistence.create(Tag.self)
        let colorIndex = information[.colorIndex] as? Int64 ?? abs(Int64(nextColor))
        let id = information[.id] as? UUID ?? UUID()
        let tasks = information[.tasks] as? [Task] ?? []
        let arriving = information[.isArrivingLocation] as? Bool ?? false
        let requiresAuthentication = information[.requiresAuthentication] as? Bool ?? false
        
        tag.requiresAuthentication = requiresAuthentication
        tag.colorIndex = colorIndex
        tag.id = id
        tag.title = title
        tag.tasks = NSSet(array: tasks)
        
        if let dueDate = information[.dueDate] as? Date {
            tag.dueDate = dueDate
        }
        if let region = information[.location] as? CLCircularRegion {
            let regionData =
                NSKeyedArchiver.archivedData(withRootObject: region)
            let placeName = information[.locationName] as! String
            
            tag.locationName = placeName
            tag.locationData = regionData
            tag.isArrivingLocation = arriving
        }
        
        return tag
    }
    
    func update(_ tag: Tag, with information: TagInformation) {
        if let dueDate = information[.dueDate] as? Date? {
            tag.dueDate = dueDate
        }
        
        if let id = information[.id] as? UUID {
            tag.id = id
        }
        if let title = information[.title] as? String {
            tag.title = title
        }
        if let tasks = information[.tasks] as? [Task] {
            tag.tasks = NSSet(array: tasks)
        }
        if let colorIndex = information[.colorIndex] as? Int64 {
            tag.colorIndex = colorIndex
        }
        if let arriving = information[.isArrivingLocation] as? Bool {
            tag.isArrivingLocation = arriving
        }
        if let requiresAuthentication = information[.requiresAuthentication] as? Bool {
            tag.requiresAuthentication = requiresAuthentication
        }
        if let region = information[.location] as? CLCircularRegion {
            let regionData = NSKeyedArchiver.archivedData(withRootObject: region)
            tag.locationData = regionData

            if let placeName = information[.locationName] as? String { tag.locationName = placeName }
            if let isArriving = information[.isArrivingLocation] as? Bool { tag.isArrivingLocation = isArriving }
        } else {
            tag.locationData = nil
        }
    }
    
    func delete(_ tag: Tag) {
        NotificationManager.removeAllNotifications(from: tag)
        persistence.delete(tag)
    }
    
    func save(_ tag: Tag) {
        //TODO: do more stuff
        persistence.save()
    }
}
