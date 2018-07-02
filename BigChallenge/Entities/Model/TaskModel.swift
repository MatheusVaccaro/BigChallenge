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
    private let persistance: PersistenceProtocol
    
    init() {
        self.persistance = Persistence()
        self.objects = Variable([])
        persistance.fetch(Task.self, predicate: nil) {
            self.objects = Variable( $0 )
        }
    }
    
    func task(at index: Int) -> Task {
        return objects.value[index]
    }
    
    public func save(object: Task) {
        objects.value.append(object)
        persistance.save()
    }
    
    public func remove(object: Task) {
        objects.value = objects.value.filter({$0.uuid != object.uuid})
        persistance.delete(object)
    }
    
    public func createTask(with title: String) -> Task {
        let task: Task = persistance.create(Task.self)
        task.id = UUID()
        task.title = title
        task.creationDate = Date()
        return task
    }

}
