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
        #if Debug
        localPersistence = MockPersistence()
        remotePersistence = nil
        #else
        localPersistence = LocalPersistence()
        remotePersistence = nil
        #endif
    }
    
    public func fetchAll<T>(_ model: T.Type) -> [T] where T : Storable {
        return localPersistence.fetchAll(model)
    }
    
    public func save(object: Storable) {
        localPersistence.save(object: object)
    }
    
    public func remove(object: Storable) {
        localPersistence.remove(object: object)
    }
    
    public func update(object: Storable) {
        localPersistence.update(object: object)
    }
    
}
