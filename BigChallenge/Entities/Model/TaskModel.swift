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
    
    lazy var objectsObservable: Driver<[Task]> = {
        return objects
            .asObservable()
            .asDriver(onErrorJustReturn: [])
    }() // TODO should this be lazy?
    
    var count: Int {
        return objects.value.count
    }
    
    private var objects: Variable<[Task]>
    private let persistance: Persistence
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.objects = Variable([])
        persistance.fetch(Task.self, predicate: nil) {
            self.objects = Variable( $0 )
        }
    }
    
    func fetchAll() -> [Task] {
        return objects.value
    }
    
    func task(at index: Int) -> Task {
        return objects.value[index]
    }
    
    public func save(object: Task) {
        objects.value.append(object)
//        RemindersImporter.instance?.save(task: object)
        persistance.save()
    }
    
    public func delete(object: Task) {
        // TODO change to removeAll when available
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
