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
    
    var persistentContainer: NSPersistentContainer
    
    init() {
        self.persistentContainer = {
            /* This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
             */
            let container = NSPersistentContainer(name: "Model")
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
    }
    
    func create<T: Storable>(_ object: T.Type) throws -> T {
        let modelName = String(describing: object)
        //swiftlint:disable:next line_length
        guard let object = NSEntityDescription.insertNewObject(forEntityName: modelName, into: persistentContainer.viewContext) as? T else {
            throw CoreDataError.couldNotCreateObject
        }
        return object
    }
    
    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate? = nil, completion: (([T]) -> Void)) throws {
        
        let context = persistentContainer.viewContext
        let entityName = String(describing: model)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            var ans = try context.fetch(request)
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
        
        let context = persistentContainer.viewContext
        let entityName = String(describing: type(of: object))
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let results = try context.fetch(request)
            if let results = results as? [NSManagedObject] {
                for result in results where result.uuid == object.uuid {
                    context.delete(result)
                }
            }
            try saveContext()
        } catch {
            throw CoreDataError.couldNotDeleteObject(reason: error.localizedDescription)
        }
    }
    
    private func saveContext () throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataError.couldNotSaveContext(reason: error.localizedDescription)
            }
        }
    }
    
}

extension NSManagedObject: Storable {
    public var uuid: UUID {
        //swiftlint:disable:next force_cast
        return value(forKey: "id") as! UUID
    }
}

enum CoreDataError: Error {
    case couldNotCreateObject
    case couldNotFetchObject(reason: String)
    case couldNotSaveContext(reason: String)
    case couldNotDeleteObject(reason: String)
}
