//
//  Persistence.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 28/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public class Persistence: PersistenceProtocol {
    
    // MARK: - Initialization Configuration Enum
    
    public enum Configuration {
        case inMemory
        case inDevice
    }

    // MARK: - Properties
    
    public weak var delegate: PersistenceDelegate?
    
    private let localPersistence: LocalPersistence
    private let remotePersistence: PersistenceProtocol?
    
    // MARK: - Persistence Lifecycle
    
    public init(configuration: Configuration = .inDevice) {
        switch configuration {
        case .inDevice:
            localPersistence = LocalPersistence()
            remotePersistence = nil
        case .inMemory:
            localPersistence = MockPersistence()
            remotePersistence = nil
        }
        localPersistence.delegate = self
    }
    
    // MARK: - CRUD Methods
    
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

// MARK: - LocalPersistenceDelegate Extension

extension Persistence: PersistenceDelegate {
    public func persistence(_ persistence: PersistenceProtocol, didInsertObjects objects: [Storable]) {
        delegate?.persistence(self, didInsertObjects: objects)
    }
    
    public func persistence(_ persistence: PersistenceProtocol, didUpdateObjects objects: [Storable]) {
        delegate?.persistence(self, didUpdateObjects: objects)
    }
    
    public func persistence(_ persistence: PersistenceProtocol, didDeleteObjects objects: [Storable]) {
        delegate?.persistence(self, didDeleteObjects: objects)
    }
}
