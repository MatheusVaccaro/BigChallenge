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

public class TagModel {
    
    var objectsObservable: Observable<[Tag]> {
        return self.objects.asObservable()
    }
    
    var count: Int {
        return objects.value.count
    }
    
    private var objects: Variable<[Tag]>
    private let persistance: Persistence
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.objects = Variable([])
        persistance.fetch(Tag.self, predicate: nil) {
            self.objects = Variable( $0 )
        }
    }
    
    func task(at index: Int) -> Tag {
        return objects.value[index]
    }
    
    public func save(object: Tag) {
        objects.value.append(object)
        persistance.save()
    }
    
    public func remove(object: Tag) {
        objects.value = objects.value.filter({$0.uuid != object.uuid})
        persistance.delete(object)
    }
    
    public func createTag(with title: String = "") -> Tag {
        let tag: Tag = persistance.create(Tag.self)
        
        tag.id = UUID()
        
        return tag
    }
    
}
