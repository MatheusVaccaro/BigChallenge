//
//  MockPersistence.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class MockPersistence: Persistence {
    
    private var objects: [Storable]
    
    init() {
        objects = {
            var tasks = [Task]()
            for iterator in 1...2 {
                tasks.append(Task(title: "Task \(iterator)"))
            }
            return tasks
        }()
    }
    
    func fetchAll<T: Storable>(_ model: T.Type) -> [T] {
        //swiftlint:disable:next force_cast
        return objects as! [T]
    }
    
    func save(object: Storable) {
        objects.append(object)
    }
    
    func remove(at index: Int) {
        objects.remove(at: index)
    }
    
}
