//
//  SpotlightDelegate.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import MobileCoreServices
import CoreSpotlight

class ReefSpotlight: NSObject {
    let taskModel: TaskModel
    let tagModel: TagModel
    
    init(taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
    }
    
    static func index(task: Task) {
        DispatchQueue.global().async {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            
            attributeSet.title = task.title!
            attributeSet.contentDescription = task.notes
            
            attributeSet.userCreated = 100
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
    }
    
    static func updateInSpotlight(task: Task) {
        deindex(task: task)
        index(task: task)
    }
    
    static func deindex(task: Task) {
        DispatchQueue.global().async {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(task.id!)"]) { error in
                if let error = error {
                    print("Deindexing error: \(error.localizedDescription)")
                }
            }
        }
    }
    // MARK: - Tag
    static func index(tag: Tag) {
        DispatchQueue.global().async {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            
            attributeSet.title = tag.title!
            attributeSet.userCreated = 100
            attributeSet.contentCreationDate = Date()
            
            let item = CSSearchableItem(uniqueIdentifier: "tag-\(tag.id!)",
                domainIdentifier: "com.beanie",
                attributeSet: attributeSet)
            
            CSSearchableIndex.default().indexSearchableItems([item]) { error in
                if let error = error {
                    print("Indexing error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    static func deindex(tag: Tag) {
        DispatchQueue.global().async {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(tag.id!)"]) { error in
                if let error = error {
                    print("Deindexing error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    static func updateInSpotlight(tag: Tag) {
        deindex(tag: tag)
        index(tag: tag)
    }
}

extension ReefSpotlight: CSSearchableIndexDelegate {
    func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        let dataStore = DispatchQueue(label: "dataStore")
        
        dataStore.async {
            group.enter()
            for task in self.taskModel.tasks { ReefSpotlight.index(task: task) }
            for tag in self.tagModel.tags { ReefSpotlight.index(tag: tag) }
            group.leave()
        }
        
        group.notify(queue: dataStore) {
            acknowledgementHandler()
        }
    }
    
    func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        let dataStore = DispatchQueue(label: "dataStore")
        
        dataStore.async {
            group.enter()
            for task in self.taskModel.tasks where identifiers.contains("task-\(task.id!.description)") {
                ReefSpotlight.index(task: task)
            }
            for tag in self.tagModel.tags where identifiers.contains("tag-\(tag.id!.description)") {
                ReefSpotlight.index(tag: tag)
            }
            group.leave()
        }
        
        group.notify(queue: dataStore) {
            acknowledgementHandler()
        }
    }
}
