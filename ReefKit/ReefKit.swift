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
        persistence.tasksDelegate = self
        persistence.tagsDelegate = self
    }
    
    public func fetchTasks(completionHandler: @escaping (([Task]) -> ())) {
        taskCRUD.fetchTasks { completionHandler($0) }
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
    
    public func fetchTags(completionHandler: @escaping (([Tag]) -> ())) {
        tagCRUD.fetchTags { completionHandler($0) }
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

extension ReefKit: TagsPersistenceDelegate {
    public func persistence(_ persistence: Persistence, didInsertTags tags: [Tag]) {
        tagsDelegate?.reef(self, didInsertTags: tags)
    }
    
    public func persistence(_ persistence: Persistence, didUpdateTags tags: [Tag]) {
        tagsDelegate?.reef(self, didUpdateTags: tags)
    }
    
    public func persistence(_ persistence: Persistence, didDeleteTags tags: [Tag]) {
        tagsDelegate?.reef(self, didDeleteTags: tags)
    }
}

extension ReefKit: TasksPersistenceDelegate {
    public func persistence(_ persistence: Persistence, didInsertTasks tasks: [Task]) {
        tasksDelegate?.reef(self, didInsertTasks: tasks)
    }
    
    public func persistence(_ persistence: Persistence, didUpdateTasks tasks: [Task]) {
        tasksDelegate?.reef(self, didUpdateTasks: tasks)
    }
    
    public func persistence(_ persistence: Persistence, didDeleteTasks tasks: [Task]) {
        tasksDelegate?.reef(self, didDeleteTasks: tasks)
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
