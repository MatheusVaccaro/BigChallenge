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
    
    enum Configuration {
        case inMemory
        case inDevice
    }
    
    
    // MARK: - Properties
    
    private let localPersistence: LocalPersistence
    private let remotePersistence: PersistenceProtocol?
    
    weak var delegate: PersistenceDelegate?
    
    
    // MARK: - Persistence Lifecycle
    
    init(configuration: Configuration = .inDevice) {
        switch configuration {
        case .inDevice:
            localPersistence = LocalPersistence()
            remotePersistence = nil
        case .inMemory:
            localPersistence = MockPersistence()
            remotePersistence = nil
        }
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


// MARK: - Persistence Delegate

protocol PersistenceDelegate: class {
    func persistence(_ persistence: Persistence, didInsertTasks tasks: [Task])
    func persistence(_ persistence: Persistence, didUpdateTasks tasks: [Task])
    func persistence(_ persistence: Persistence, didDeleteTasks tasks: [Task])
    
    func persistence(_ persistence: Persistence, didInsertTags tags: [Tag])
    func persistence(_ persistence: Persistence, didUpdateTags tags: [Tag])
    func persistence(_ persistence: Persistence, didDeleteTags tags: [Tag])
}

extension PersistenceDelegate {
    func persistence(_ persistence: Persistence, didInsertTasks tasks: [Task]) { }
    func persistence(_ persistence: Persistence, didUpdateTasks tasks: [Task]) { }
    func persistence(_ persistence: Persistence, didDeleteTasks tasks: [Task]) { }
    
    func persistence(_ persistence: Persistence, didInsertTags tags: [Tag]) { }
    func persistence(_ persistence: Persistence, didUpdateTags tags: [Tag]) { }
    func persistence(_ persistence: Persistence, didDeleteTags tags: [Tag]) { }
}


// MARK: - LocalPersistenceDelegate Extension

extension Persistence: LocalPersistenceDelegate {
    
    func localPersistence(_ localPersistence: LocalPersistence, didInsertObjects objects: [Storable]) {
        if let tasks = (objects.filter { $0 is Task }) as? [Task] {
            delegate?.persistence(self, didInsertTasks: tasks)
        }
        
        if let tags = (objects.filter { $0 is Tag }) as? [Tag] {
            delegate?.persistence(self, didInsertTags: tags)
        }
    }
    
    func localPersistence(_ localPersistence: LocalPersistence, didUpdateObjects objects: [Storable]) {
        if let tasks = (objects.filter { $0 is Task }) as? [Task] {
            delegate?.persistence(self, didUpdateTasks: tasks)
        }
        
        if let tags = (objects.filter { $0 is Tag }) as? [Tag] {
            delegate?.persistence(self, didUpdateTags: tags)
        }
    }
    
    func localPersistence(_ localPersistence: LocalPersistence, didDeleteObjects objects: [Storable]) {
        if let tasks = (objects.filter { $0 is Task }) as? [Task] {
            delegate?.persistence(self, didDeleteTasks: tasks)
        }
        
        if let tags = (objects.filter { $0 is Tag }) as? [Tag] {
            delegate?.persistence(self, didDeleteTags: tags)
        }
    }

}
