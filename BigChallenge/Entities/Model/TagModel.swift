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
    
    private(set) var didUpdateTags: BehaviorSubject<[Tag]> //(([Tag]) -> Void)?
    
    private(set) public var tags: [Tag]
    private let persistance: Persistence
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.tags = []
        self.didUpdateTags = BehaviorSubject<[Tag]>(value: tags)
        
        persistence.fetch(Tag.self) {
            tags = $0
        }
        
        
        persistence.didAddTags = {
            for tag in $0 { //filter tags added by this device
                guard !self.tags.contains(tag) else { continue }
                self.tags.append(tag)
                self.didUpdateTags.onNext(self.tags)
            }
        }
        didUpdateTags.onNext(tags)
    }
    
    public func saveContext() {
        persistance.save()
    }
    
    public func save(object: Tag) {
        guard !tags.contains(object) else { return }
        tags.append(object)
        persistance.save()
        didUpdateTags.onNext(tags)
    }
    
    public func delete(object: Tag) {
        guard let tagIndex = tags.index(of: object) else { print("could not delete \(object) "); return }
        // TODO change to removeAll when available
        persistance.delete(object)
        tags.remove(at: tagIndex)
        didUpdateTags.onNext(tags)
    }
    
    public func createTag(with title: String) -> Tag {
        if let tag = (tags.first { $0.title == title }) { return tag }
        else { // dont create repeated tags
            let tag: Tag = persistance.create(Tag.self)
            
            tag.id = UUID()
            tag.title = title
            
            return tag
        }
    }
}
