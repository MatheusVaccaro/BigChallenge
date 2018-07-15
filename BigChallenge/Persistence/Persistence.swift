//
//  Persistence.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 28/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public class Persistence: PersistenceProtocol {
    
    enum Configuration {
        case inMemory
        case inDevice
    }
   
    let localPersistence: PersistenceProtocol
    let remotePersistence: PersistenceProtocol?
    
    init(configuration: Configuration = .inDevice) {
        switch configuration {
        case .inDevice:
            localPersistence = LocalPersistence()
            remotePersistence = nil
        case .inMemory:
            localPersistence = MockPersistence()
            remotePersistence = nil
        }
        //TODO: Find better alternative to setup mock or normal persistence. DEBUG in test target only maybe?
//        #if DEBUG
//        localPersistence = MockPersistence()
//        remotePersistence = nil
//        print("--- LAUNCHING IN DEBUG MODE ---")
//        print("--- USING MOCK PERSISTENCE ----")
//        #else
//        localPersistence = LocalPersistence()
//        remotePersistence = nil
//        print("------------ WARNING ------------")
//        print("--- LAUNCHING IN RELEASE MODE ---")
//        print("----- USING PROD PERSISTENCE ----")
//        #endif
    }
    
    public func create<T: Storable>(_ model: T.Type) -> T {
        do {
            return try localPersistence.create(model)
        } catch CoreDataError.couldNotCreateObject {
            fatalError("Could not create object in local persistence.")
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
    
    public func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate? = nil, completion: (([T]) -> Void)) {
        do {
            try localPersistence.fetch(model, predicate: predicate, completion: completion)
        } catch CoreDataError.couldNotFetchObject(let reason) {
            fatalError(reason)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
    
    public func save() {
        do {
            try localPersistence.save()
        } catch CoreDataError.couldNotSaveContext(let reason) {
            fatalError(reason)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
    
    public func delete(_ object: Storable) {
        do {
            try localPersistence.delete(object)
        } catch CoreDataError.couldNotDeleteObject(let reason) {
            fatalError(reason)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}
