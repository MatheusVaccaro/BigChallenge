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

public class ReefSpotlight: NSObject {
    public static func index(task: Task) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        attributeSet.title = task.title!
        attributeSet.contentDescription = task.notes
        
        attributeSet.userOwned = 1
        
        attributeSet.dueDate = task.dates.min()
        //TODO add location
//        attributeSet.contentCreationDate = task.creationDate
        
        let item = CSSearchableItem(uniqueIdentifier: "task-\(task.id!)",
            domainIdentifier: "com.beanie",
            attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }
        }
    }
    
    public static func updateInSpotlight(task: Task) {
        ReefSpotlight.deindex(task: task)
        ReefSpotlight.index(task: task)
    }
    
    public static func deindex(task: Task) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(task.id!)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            }
        }
    }
    
    public static func index(tag: Tag) {
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
    
    public static func deindex(tag: Tag) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(tag.id!)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            }
        }
    }
    
    public static func updateInSpotlight(tag: Tag) {
        ReefSpotlight.deindex(tag: tag)
        ReefSpotlight.index(tag: tag)
    }
}
