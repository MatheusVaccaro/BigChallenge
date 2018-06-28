 //
 //  MockPersistence.swift
 //  BigChallenge
 //
 //  Created by Matheus Vaccaro on 25/05/18.
 //  Copyright © 2018 Matheus Vaccaro. All rights reserved.
 //
 
 import Foundation
 import CoreData
 
class LocalPersistence: PersistenceProtocol {
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /* This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CheckContainer")
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
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private var objects: [Storable]
    
    init() {
        //fetch all objects from LocalPersistance
        objects = []
        objects = fetchAll(Task.self)
    }
    
    func fetchAll<T: Storable>(_ model: T.Type) -> [T] {
        var ans: [T] = []
        guard
            let model = model as? CDStorable
            else { print("object not CDStorable"); return ans }
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: model.entityName)
        
        do {
            ans = try persistentContainer.viewContext.fetch(fetchRequest) as! [T]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return ans
    }
    
    func save(object: Storable) {
        guard let object =
            object as? CDStorable else {
                print("object not CDStorable")
                return
            }
        
        _ = object.managedObject(for: persistentContainer.viewContext)
        
        saveContext()
    }
    
    func remove(object: Storable) {
        guard let object = object as? CDStorable
            else {
                print("object not CDStorable")
                return
        }
        
        let context = persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: object.entityName)
        
        if let result = try? context.fetch(fetchRequest) {
            for cdObject in result where cdObject.uuid == object.uuid {
                context.delete(cdObject)
            }
        }
        
        saveContext()
    }
    
    func update(object: Storable) {
        objects =
            objects.map {
                if $0.uuid == object.uuid {
                    return object
                }
                return $0
        }
    }
 }
 
 private protocol CDStorable: Storable {
    var entityName: String { get }
    func managedObject(for context: NSManagedObjectContext) -> NSManagedObject
 }
 
extension Task: CDStorable {
    
    var entityName: String {
        return "TaskEntity"
    }
    
    func managedObject(for context: NSManagedObjectContext) -> NSManagedObject {
        let entity =
            NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        let object =
            NSManagedObject(entity: entity, insertInto: context)
        
        object.setValue(uuid, forKey: "UUID")
        
        return object
    }
}
 
 extension NSManagedObject: Storable {
    public var uuid: UUID {
        return value(forKey: "UUID") as! UUID
    }
 }
