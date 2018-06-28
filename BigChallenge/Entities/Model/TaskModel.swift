//
//  TaskModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class TaskModel {
    
    var objectsObservable: Observable<[Task]> {
        return self.objects.asObservable()
    }
    
    var count: Int {
        return objects.value.count
    }
    
    private var objects: Variable<[Task]>
    private let persistance: Persistence
    
    func task(at index: Int) -> Task {
        return objects.value[index]
    }
    
    func save(object: Storable) {
        if let object = object as? Task {
            objects.value.append(object)
        }
        persistance.save(object: object)
    }
    
    func remove(object: Storable) {
        objects.value = objects.value.filter({$0.uuid != object.uuid})
        persistance.remove(object: object)
    }
    
    func update(object: Storable) {
        objects.value =
            objects.value.map {
            if $0.uuid == object.uuid {
                if let object = object as? Task { return object }
            }
            return $0
        }
        persistance.update(object: object)
    }

    init(_ persistence: Persistence) {
        self.persistance = persistence
        self.objects = Variable(persistance.fetchAll(Task.self))
    }
}
