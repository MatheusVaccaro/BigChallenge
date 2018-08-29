//
//  LocalPersistence.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreData

class LocalPersistence: PersistenceProtocol {
    
    // MARK: - Properties
    
    // This property is internal because MockPersistence needs to set it inside its init()
    internal var persistentContainer: NSPersistentContainer
    
    private var notificationCenter = NotificationCenter.default
    
    private lazy var viewContext = {
       return persistentContainer.viewContext
    }()
    
    weak var delegate: PersistenceDelegate?
    
    // MARK: - LocalPersistence Lifecycle
    
    init() {
        self.persistentContainer = {
            /* This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
             */
            let customKitBundle = Bundle(identifier: "com.Wide.ReefKit")!
            let modelURL = customKitBundle.url(forResource: "Model", withExtension: "momd")!
            let model = NSManagedObjectModel(contentsOf: modelURL)!
            
            let container = NSPersistentContainer(name: "Model", managedObjectModel: model)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        
        setupContextDidChangeObserver()
        setupContextWillSaveObserver()
        setupContextDidSaveObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - CRUD Methods
    
    func create<T: Storable>(_ object: T.Type) throws -> T {
        let modelName = String(describing: object)
        guard let object = NSEntityDescription.insertNewObject(forEntityName: modelName, into: viewContext) as? T else {
            throw CoreDataError.couldNotCreateObject
        }
        return object
    }
    
    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate? = nil, completion: (([T]) -> Void)) throws {
        let entityName = String(describing: model)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            var ans = try viewContext.fetch(request)
            if let predicate = predicate,
                let unfilteredAns = ans as? [NSManagedObject] {
                ans = unfilteredAns.filter { predicate.evaluate(with: $0) }
            }
            //swiftlint:disable:next force_cast
            completion(ans as! [T])
        } catch {
            throw CoreDataError.couldNotFetchObject(reason: error.localizedDescription)
        }
    }
    
    func save() throws {
        try saveContext()
    }
    
    func delete(_ object: Storable) throws {
        let entityName = String(describing: type(of: object))
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let results = try viewContext.fetch(request)
            if let results = results as? [NSManagedObject] {
                for result in results where result.uuid == object.uuid {
                    viewContext.delete(result)
                }
            }
            try saveContext()
        } catch {
            throw CoreDataError.couldNotDeleteObject(reason: error.localizedDescription)
        }
    }
    
    // MARK: - CRUD Auxiliary Methods
    
    private func saveContext () throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                throw CoreDataError.couldNotSaveContext(reason: error.localizedDescription)
            }
        }
    }
    
    // MARK: - CoreData Observers Setup
    
    private func setupContextDidChangeObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidChange(_:)),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: viewContext)
    }
    
    @objc private func contextDidChange(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let insertSet = userInfo[NSInsertedObjectsKey] as? NSSet,
            let insertArray = insertSet.allObjects as? [Storable] {
            delegate?.persistence(self, didInsertObjects: insertArray)
        }
        
        if let updateSet = userInfo[NSUpdatedObjectsKey] as? NSSet,
            let updateArray = updateSet.allObjects as? [Storable] {
            delegate?.persistence(self, didUpdateObjects: updateArray)
        }
        
        if let deleteSet = userInfo[NSDeletedObjectsKey] as? NSSet,
            let deleteArray = deleteSet.allObjects as? [Storable] {
            delegate?.persistence(self, didDeleteObjects: deleteArray)
        }
    }
    
    private func setupContextWillSaveObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextWillSave(_:)),
                                               name: Notification.Name.NSManagedObjectContextWillSave,
                                               object: viewContext)
    }
    
    @objc private func contextWillSave(_ notification: NSNotification) {
        delegate?.willSaveContext(in: self)
        
    }
    
    private func setupContextDidSaveObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidSave(_:)),
                                               name: Notification.Name.NSManagedObjectContextDidSave,
                                               object: viewContext)
    }
    
    @objc private func contextDidSave(_ notification: NSNotification) {
        delegate?.didSaveContext(in: self)
        
    }
}

// MARK: - LocalPersistence Errors

enum CoreDataError: Error {
    case couldNotCreateObject
    //    TODO: solve this linter problem with xcode beta
    //     swiftlint:disable all
    case couldNotFetchObject(reason: String)
    case couldNotSaveContext(reason: String)
    case couldNotDeleteObject(reason: String)
//     swiftlint:enable all
}
