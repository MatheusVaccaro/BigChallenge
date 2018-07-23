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
    
    internal var persistentContainer: NSPersistentContainer
    internal lazy var viewContext = {
       return persistentContainer.viewContext
    }()
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangePersistence(_:)),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // todo when did change
    var didChangeObjects: (([Storable]) -> Void)?
    var didDeleteObjects: (([Storable]) -> Void)?
    var didAddObjects: (([Storable]) -> Void)?
    
    @objc private func didChangePersistence(_ notification: Notification) {
        let dict = notification.userInfo!
        
        if let addedSet = dict[NSInsertedObjectsKey] as? NSSet,
            let addedArray = addedSet.allObjects as? [Storable] {
            self.didAddObjects?(addedArray)
        }
        //TODO if let changed
        //TODO if let deleted
    }
    
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
    
    private func saveContext () throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                throw CoreDataError.couldNotSaveContext(reason: error.localizedDescription)
            }
        }
    }
    
    func clearDatabase() {
        
        let entityName = "Task"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch {
            print(error.localizedDescription)
        }
        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        let result = try! viewContext.fetch(request) as! [NSManagedObject]
//        result.forEach {
//            viewContext.delete($0)
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
    }
    
}

enum CoreDataError: Error {
    case couldNotCreateObject
    //    TODO: tirar essa merda daqui eventualmente, ja que o linter nao funciona com o xcode9 e 10 ao mesmo tempo, dai nao da trabalhar com mais de uma pessoa ao mesmo tempo
    //     swiftlint:disable all
    case couldNotFetchObject(reason: String)
    case couldNotSaveContext(reason: String)
    case couldNotDeleteObject(reason: String)
//     swiftlint:enable all
}
