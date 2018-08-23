//
//  ReefKit.swift
//  ReefKit
//
//  Created by Bruno Fulber Wide on 23/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public class ReefKit {
    private let taskCRUD: TaskCRUD
    private let tagCRUD: TagCRUD
    public let persistence: Persistence
    
    public init() {
        self.persistence = Persistence(configuration: .inDevice)
        self.taskCRUD = TaskCRUD(persistence: persistence)
        self.tagCRUD = TagCRUD(persistence: persistence)
    }
    
    public func fetchTasks(completionHandler: @escaping (([Task]) -> ())) {
        taskCRUD.fetchTasks { completionHandler($0) }
    }
    
    public func createTask(with attributes: [TaskAttributes : Any]) -> Task? {
        let task = taskCRUD.createTask(with:attributes)
        return task
    }
    public func update(_ task: Task, with attributes: [TaskAttributes : Any]) {
        taskCRUD.update(task, with: attributes)
    }
    public func delete(_ task: Task) {
        taskCRUD.delete(task)
    }
    
    public func fetchTag(completionHandler: @escaping (([Tag]) -> ())) {
        tagCRUD.fetchTags { completionHandler($0) }
    }
    
    public func createTag(with attributes: [TagAttributes : Any]) -> Tag? {
        let tag = tagCRUD.createTag(with: attributes)
        return tag
    }
    public func update(_ tag: Tag, with attributes: [TagAttributes : Any]) {
        tagCRUD.update(tag, with: attributes)
    }
    public func delete(_ tag: Tag) {
        tagCRUD.delete(tag)
    }
}
