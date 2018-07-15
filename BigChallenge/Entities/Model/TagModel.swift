//
//  TagModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class TagModel {
    
    var didAddTags: (([Tag]) -> Void)?
    
    private(set) public var tags: [Tag]
    private let persistance: Persistence
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.tags = []
        
        persistence.didAddTags = {
            self.tags.append(contentsOf: $0)
            self.didAddTags?($0)
        }
    }
    
    public func save(object: Tag) {
        tags.append(object)
        persistance.save()
    }
    
    public func remove(object: Tag) {
        guard let tagIndex = tags.firstIndex(of: object) else { print("could not delete \(object) "); return }
        persistance.delete(object)
        tags.remove(at: tagIndex)
    }
    
    public func createTag(with title: String = "") -> Tag {
        let tag: Tag = persistance.create(Tag.self)
        
        tag.id = UUID()
        tag.title = title
        
        return tag
    }
}
