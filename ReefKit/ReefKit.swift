//
//  ReefKit.swift
//  ReefKit
//
//  Created by Bruno Fulber Wide on 23/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import Persistence

public class ReefKit {
    public weak var tasksDelegate: ReefTaskDelegate?
    public weak var tagsDelegate: ReefTagDelegate?
    public var nextColor: Int64 {
        return tagCRUD.nextColor
    }
    
    private let taskCRUD: TaskCRUD
    private let tagCRUD: TagCRUD
    private let persistence: Persistence
    
    public init() {
        self.persistence = Persistence(configuration: .inDevice)
        self.taskCRUD = TaskCRUD(persistence: persistence)
        self.tagCRUD = TagCRUD(persistence: persistence)
        persistence.delegate = self
    }
    
    public func refresh() {
        persistence.refresh()
    }
    
    public func fetchTasks(predicate: NSPredicate = NSPredicate(value: true), completionHandler: @escaping (([Task]) -> ())) {
        taskCRUD.fetchTasks(predicate: predicate) { completionHandler($0) }
    }
    
    public func createTask(with information: TaskInformation) -> Task {
        let task = taskCRUD.createTask(with:information)
        return task
    }
    public func update(_ task: Task, with information: TaskInformation) {
        taskCRUD.update(task, with: information)
        ReefSpotlight.updateInSpotlight(task: task)
        save(task)
    }
    public func save(_ task: Task) {
        ReefSpotlight.index(task: task)
        taskCRUD.save(task)
    }
    
    /**
     Batch save. Intent is to trigger only one persistence change notification.
 	*/
    public func save(_ tasks: [Task]) {
        for task in tasks {
            ReefSpotlight.index(task: task)
        }
        if let firstTask = tasks.first {
            // This is done like this because, as of now, the method below saves the current context. That said:
            // TODO: Refactor local persistence to support single-task saving, instead of saving all tasks in current context
            taskCRUD.save(firstTask)
        }
    }
    
    public func delete(_ task: Task) {
        ReefSpotlight.deindex(task: task)
        taskCRUD.delete(task)
    }
    
    public func fetchTags(predicate: NSPredicate? = nil, completionHandler: @escaping (([Tag]) -> ())) {
        tagCRUD.fetchTags(predicate: predicate) { completionHandler($0) }
    }
    
    public func createTag(with information: TagInformation) -> Tag {
        let tag = tagCRUD.createTag(with: information)
        return tag
    }
    public func update(_ tag: Tag, with information: TagInformation) {
        tagCRUD.update(tag, with: information)
        ReefSpotlight.updateInSpotlight(tag: tag)
        save(tag)
    }
    public func save(_ tag: Tag) {
        ReefSpotlight.index(tag: tag)
        tagCRUD.save(tag)
    }
    /**
     Batch save. Intent is to trigger only one persistence change notification.
     */
    public func save(_ tags: [Tag]) {
        for tag in tags {
            ReefSpotlight.index(tag: tag)
        }
        if let firstTag = tags.first {
            // This is done like this because, as of now, the method below saves the current context. That said:
            // TODO: Refactor local persistence to support single-task saving, instead of saving all tasks in current context
            tagCRUD.save(firstTag)
        }
    }
    
    public func delete(_ tag: Tag) {
        ReefSpotlight.deindex(tag: tag)
        tagCRUD.delete(tag)
    }
}

extension ReefKit: PersistenceDelegate {
    public func persistence(_ persistence: PersistenceProtocol, didInsertObjects objects: [Storable]) {
        DispatchQueue.main.async {
            if let tasks = (objects.filter { $0 is Task }) as? [Task], !tasks.isEmpty {
                self.tasksDelegate?.reef(self, didInsertTasks: tasks)
            }
            
            if let tags = (objects.filter { $0 is Tag }) as? [Tag], !tags.isEmpty {
                self.tagsDelegate?.reef(self, didInsertTags: tags)
            }
        }
    }
    
    public func persistence(_ persistence: PersistenceProtocol, didUpdateObjects objects: [Storable]) {
        DispatchQueue.main.async {
            if let tasks = (objects.filter { $0 is Task }) as? [Task], !tasks.isEmpty {
                self.tasksDelegate?.reef(self, didUpdateTasks: tasks)
            }
            
            if let tags = (objects.filter { $0 is Tag }) as? [Tag], !tags.isEmpty {
                self.tagsDelegate?.reef(self, didUpdateTags: tags)
            }
        }
    }
    
    public func persistence(_ persistence: PersistenceProtocol, didDeleteObjects objects: [Storable]) {
        DispatchQueue.main.async {
            if let tasks = (objects.filter { $0 is Task }) as? [Task], !tasks.isEmpty {
                self.tasksDelegate?.reef(self, didDeleteTasks: tasks)
            }
            
            if let tags = (objects.filter { $0 is Tag }) as? [Tag], !tags.isEmpty {
                self.tagsDelegate?.reef(self, didDeleteTags: tags)
            }
        }
    }
}

// MARK: - Reef Delegate
// MARK: Tasks
public protocol ReefTaskDelegate: class {
    func reef(_ reefKit: ReefKit, didInsertTasks tasks: [Task])
    func reef(_ reefKit: ReefKit, didUpdateTasks tasks: [Task])
    func reef(_ reefKit: ReefKit, didDeleteTasks tasks: [Task])
}

// MARK: Tags
public protocol ReefTagDelegate: class {
    func reef(_ reefKit: ReefKit, didInsertTags tags: [Tag])
    func reef(_ reefKit: ReefKit, didUpdateTags tags: [Tag])
    func reef(_ reefKit: ReefKit, didDeleteTags tags: [Tag])
}
