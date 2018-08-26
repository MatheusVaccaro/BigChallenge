//
//  IndexRequestHandler.swift
//  IndexExtension
//
//  Created by Bruno Fulber Wide on 23/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import CoreSpotlight
import ReefKit

//TODO
class IndexRequestHandler: CSIndexExtensionRequestHandler {

    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexAllSearchableItemsWithAcknowledgementHandler acknowledgementHandler: @escaping () -> Void) {
        // Reindex all data with the provided index
        DispatchQueue.global(qos: .background).sync {
            let reef = ReefKit()
            
            reef.fetchTasks { for task in $0 { ReefSpotlight.index(task: task) } }
            reef.fetchTags { for tag in $0 { ReefSpotlight.index(tag: tag) } }
        
            acknowledgementHandler()
        }
    }
    
    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: @escaping () -> Void) {
        // Reindex any items with the given identifiers and the provided index
        DispatchQueue.global(qos: .background).sync {
            let reef = ReefKit()
            
            let tagID = "tag-"
            let taskID = "task-"
            
            let tagIDs = identifiers
                .filter { $0.hasPrefix(tagID) }
                .map { String( $0.dropFirst(tagID.count)) }
            
            let taskIDs = identifiers
                .filter { $0.hasPrefix(taskID) }
                .map { String( $0.dropFirst(taskID.count) ) }
            
            reef.fetchTasks() {
                for task in $0 where taskIDs.contains(task.id!.description) {
                        ReefSpotlight.index(task: task)
                }
            }
            reef.fetchTags {
                for tag in $0 where tagIDs.contains(tag.id!.description) {
                    ReefSpotlight.index(tag: tag)
                }
            }
        
            acknowledgementHandler()
        }
    }
    
    override func data(for searchableIndex: CSSearchableIndex, itemIdentifier: String, typeIdentifier: String) throws -> Data {
        // Replace with Data representation of requested type from item identifier
        
        return Data() //TODO: add data when ipad app is available
    }
}
