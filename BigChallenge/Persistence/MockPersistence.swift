//
//  MockPersistence.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class MockPersistence: PersistenceProtocol {
    func fetch<T>(_ model: T.Type, predicate: NSPredicate? = nil, completion: (([T]) -> ())) where T : Storable {
        completion( objects as! [T] )
    }
    
    
    private var objects: [Storable]
    
    init() {
        objects = {
            var tasks: [Task] = [] // this wont work if we target this file for Tests
                                   // ?????????????
            for iterator in 1...2 {
                //TODO \o/
            }
            return tasks
        }()
        objects = []
    }
    
    func save(object: Storable) {
        objects.append(object)
    }
    
    func remove(object: Storable) {
        objects = objects.filter({$0.uuid != object.uuid})
    }
    
    func update(object: Storable) {
        //TODO: make this equal to the taskmodel
        objects = objects.map {
            var mutableObject = $0
            if $0.uuid == object.uuid {
                mutableObject = object
            }
            return mutableObject
        }
    }
}
