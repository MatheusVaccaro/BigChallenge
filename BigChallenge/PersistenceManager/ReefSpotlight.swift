//
//  ReefSpotlight.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices
import ReefKit

class ReefSpotlight {
    static func index(task: Task) {
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
    
    static func updateInSpotlight(task: Task) {
        ReefSpotlight.deindex(task: task)
        ReefSpotlight.index(task: task)
    }
    
    static func deindex(task: Task) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(task.id!)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            }
        }
    }
    
    static func index(tag: Tag) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        attributeSet.title = tag.title!
        
        let item = CSSearchableItem(uniqueIdentifier: "tag-\(tag.id!)",
            domainIdentifier: "com.beanie",
            attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }
        }
    }
    
    static func deindex(tag: Tag) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(tag.id!)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            }
        }
    }
    
    static func updateInSpotlight(tag: Tag) {
        ReefSpotlight.deindex(tag: tag)
        ReefSpotlight.index(tag: tag)
    }
}
