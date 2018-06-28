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
 
 public class LocalPersistence: Persistence {
    
    private var objects: [Storable]
    
    init() {
        objects = []
    }
    
    func fetchAll<T: Storable>(_ model: T.Type) -> [T] {
        return objects as! [T]
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
        objects = objects.filter({$0.uuid != object.uuid})
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
    func managedObject(for context: NSManagedObjectContext) -> NSManagedObject
 }
 
extension Task: CDStorable {
    func managedObject(for context: NSManagedObjectContext) -> NSManagedObject {
        let entity =
            NSEntityDescription.entity(forEntityName: "TaskEntity", in: context)!
        
        let object =
            NSManagedObject(entity: entity, insertInto: context)
        
        //TODO: set task object
        object.setValue(uuid, forKey: "UUID")
        
        return object
    }
 }
 
 extension NSManagedObject: Storable {
    var uuid: UUID {
        return value(forKey: "UUID") as! UUID
    }
 }
