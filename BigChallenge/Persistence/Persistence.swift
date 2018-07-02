//
//  Persistence.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 28/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public class Persistence: PersistenceProtocol {
   
    let localPersistence: PersistenceProtocol
    let remotePersistence: PersistenceProtocol?
    
    init() {
        #if DEBUG
        localPersistence = MockPersistence()
        remotePersistence = nil
        print("--- LAUNCHING IN DEBUG MODE ---")
        print("--- USING MOCK PERSISTENCE ----")
        #else
        localPersistence = LocalPersistence()
        remotePersistence = nil
        print("------------ WARNING ------------")
        print("--- LAUNCHING IN RELEASE MODE ---")
        print("----- USING PROD PERSISTENCE ----")
        #endif
    }
    
    public func create<T: Storable>(_ model: T.Type) -> T {
        return localPersistence.create(model)
    }
    
    public func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate? = nil, completion: (([T]) -> ())) {
        localPersistence.fetch(model, predicate: predicate, completion: completion)
    }
    
    public func save() {
        localPersistence.save()
    }
    
    public func delete(_ object: Storable) {
        localPersistence.delete(object)
    }
}
