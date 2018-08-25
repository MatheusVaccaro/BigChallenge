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
        let group = DispatchGroup()
        
        let reef = ReefKit()
        
        reef.fetchTasks { for task in $0 { ReefSpotlight.index(task: task) } }
        reef.fetchTags { for tag in $0 { ReefSpotlight.index(tag: tag) } }
        
        group.notify(queue: .global(qos: .utility)) {
            acknowledgementHandler()
        }
    }
    
    override func searchableIndex(_ searchableIndex: CSSearchableIndex, reindexSearchableItemsWithIdentifiers identifiers: [String], acknowledgementHandler: @escaping () -> Void) {
        // Reindex any items with the given identifiers and the provided index
        let group = DispatchGroup()
        let reef = ReefKit()
        
        let ids = identifiers.map { String($0.prefix { $0 != "-" }) } //TODO: verify this
        
        reef.fetchTasks { for task in $0 where ids.contains(task.id!.description) { ReefSpotlight.index(task: task) } }
        reef.fetchTags { for tag in $0 where ids.contains(tag.id!.description) { ReefSpotlight.index(tag: tag) } }
        
        group.notify(queue: .global(qos: .utility)) {
            acknowledgementHandler()
        }
    }
    
    override func data(for searchableIndex: CSSearchableIndex, itemIdentifier: String, typeIdentifier: String) throws -> Data {
        // Replace with Data representation of requested type from item identifier
        
        return Data() //TODO: add data when ipad app is available
    }
}
