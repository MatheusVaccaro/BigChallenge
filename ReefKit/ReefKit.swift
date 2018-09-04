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
    
    private let taskCRUD: TaskCRUD
    private let tagCRUD: TagCRUD
    private let persistence: Persistence
    
    public init() {
        self.persistence = Persistence(configuration: .inDevice)
        self.taskCRUD = TaskCRUD(persistence: persistence)
        self.tagCRUD = TagCRUD(persistence: persistence)
        persistence.delegate = self
    }
    
    public static func recommendedTasks(from tasks: [Task]) -> [Task] {
        return Recommender.recommended(from: tasks)
    }
    
    public func fetchTasks(predicate: NSPredicate = NSPredicate(value: true), completionHandler: @escaping (([Task]) -> ())) {
        taskCRUD.fetchTasks(predicate: predicate) { completionHandler($0) }
    }
    
    public func createTask(with attributes: [TaskAttributes : Any]) -> Task {
        let task = taskCRUD.createTask(with:attributes)
        ReefSpotlight.index(task: task)
        save(task)
        return task
    }
    public func update(_ task: Task, with attributes: [TaskAttributes : Any]) {
        taskCRUD.update(task, with: attributes)
        ReefSpotlight.updateInSpotlight(task: task)
        save(task)
    }
    public func save(_ task: Task) {
        taskCRUD.save(task)
    }
    public func delete(_ task: Task) {
        ReefSpotlight.deindex(task: task)
        taskCRUD.delete(task)
    }
    
    public func fetchTags(predicate: NSPredicate? = nil, completionHandler: @escaping (([Tag]) -> ())) {
        tagCRUD.fetchTags(predicate: predicate) { completionHandler($0) }
    }
    
    public func createTag(with attributes: [TagAttributes : Any]) -> Tag {
        let tag = tagCRUD.createTag(with: attributes)
        ReefSpotlight.index(tag: tag)
        return tag
    }
    public func update(_ tag: Tag, with attributes: [TagAttributes : Any]) {
        tagCRUD.update(tag, with: attributes)
        ReefSpotlight.updateInSpotlight(tag: tag)
        save(tag)
    }
    public func save(_ tag: Tag) {
        tagCRUD.save(tag)
    }
    public func delete(_ tag: Tag) {
        ReefSpotlight.deindex(tag: tag)
        tagCRUD.delete(tag)
    }
}

extension ReefKit: PersistenceDelegate {
    public func persistence(_ persistence: PersistenceProtocol, didInsertObjects objects: [Storable]) {
        if let tasks = (objects.filter { $0 is Task }) as? [Task], !tasks.isEmpty {
            tasksDelegate?.reef(self, didInsertTasks: tasks)
        }

        if let tags = (objects.filter { $0 is Tag }) as? [Tag], !tags.isEmpty {
            tagsDelegate?.reef(self, didInsertTags: tags)
        }
    }
    
    public func persistence(_ persistence: PersistenceProtocol, didUpdateObjects objects: [Storable]) {
        if let tasks = (objects.filter { $0 is Task }) as? [Task], !tasks.isEmpty {
            tasksDelegate?.reef(self, didUpdateTasks: tasks)
        }
        
        if let tags = (objects.filter { $0 is Tag }) as? [Tag], !tags.isEmpty {
            tagsDelegate?.reef(self, didUpdateTags: tags)
        }
    }
    
    public func persistence(_ persistence: PersistenceProtocol, didDeleteObjects objects: [Storable]) {
        if let tasks = (objects.filter { $0 is Task }) as? [Task], !tasks.isEmpty {
            tasksDelegate?.reef(self, didDeleteTasks: tasks)
        }
        
        if let tags = (objects.filter { $0 is Tag }) as? [Tag], !tags.isEmpty {
            tagsDelegate?.reef(self, didDeleteTags: tags)
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
