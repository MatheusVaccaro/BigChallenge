 //
 //  MockPersistence.swift
 //  BigChallenge
 //
 //  Created by Matheus Vaccaro on 25/05/18.
 //  Copyright © 2018 Matheus Vaccaro. All rights reserved.
 //
 
 import Foundation
 import CoreData
 import UIKit
 
class LocalPersistence: Persistence {
    
    private var objects: [Storable]
    
    init() {
        //fetch all objects from LocalPersistance
        objects = []
        objects = fetchAll(Task.self)
    }
    
    func fetchAll<T: Storable>(_ model: T.Type) -> [T] {
        var ans: [T] = []
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let model = model as? CDStorable
            else { print("object not CDStorable"); return ans }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: model.entityName)
        
        do {
            ans = try managedContext.fetch(fetchRequest) as! [T]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return ans
    }
    
    func save(object: Storable) {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let object = object as? CDStorable
            else {
                print("object not CDStorable")
                return
            }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        _ = object.managedObject(for: managedContext)
        
        do {
            try managedContext.save()
            objects.append(object)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func remove(object: Storable) {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let object = object as? CDStorable
            else {
                print("object not CDStorable")
                return
        }
        
        let context =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: object.entityName)
        
        if let result = try? context.fetch(fetchRequest) {
            for cdObject in result where cdObject.uuid == object.uuid {
                context.delete(cdObject)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not delete \(object). \(error), \(error.userInfo)")
        }
    }
    
    func remove(at index: Int) {
        objects.remove(at: index)
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
    var entityName: String {get}
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
    var uuid: UUID {
        return value(forKey: "UUID") as! UUID
    }
 }
