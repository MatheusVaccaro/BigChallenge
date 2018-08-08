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
    
    // MARK: - Properties
    
    static let tagColors = [ UIColor.Tags.purpleGradient,
                             UIColor.Tags.redGradient,
                             UIColor.Tags.peachGradient,
                             UIColor.Tags.greenGradient ]
    
    private(set) var didUpdateTags: BehaviorSubject<[Tag]>
    private(set) public var tags: [Tag]
    
    private let persistance: Persistence
    private var _nextColor: Int //TODO: save to user defaults
    private var nextColor: Int64 {
        _nextColor += 1
        return Int64( _nextColor % TagModel.tagColors.count )
    }
    
    // MARK: - TagModel Lifecyce
    
    init(persistence: Persistence) {
        self.persistance = persistence
        self.tags = []
        self.didUpdateTags = BehaviorSubject<[Tag]>(value: tags)
        self._nextColor = 0
        
        persistance.tagsDelegate = self
        persistence.fetch(Tag.self) {
            tags = $0
        }
        didUpdateTags.onNext(tags)
    }
    
    // MARK: - CRUD Methods
    
    public func saveContext() {
        persistance.save()
    }
    
    public func save(_ tag: Tag) {
        if !tags.contains(tag) { tags.append(tag) }
        persistance.save() // delegate manages the array
    }
    
    public func delete(object: Tag) {
        guard tags.contains(object) else { print("could not delete \(object) "); return }
        persistance.delete(object) // delegate manages the array
    }
    
    public func createTag(with title: String) -> Tag {
        if let tag = (tags.first { $0.title == title }) {
            return tag
        } else { // dont create repeated tags
            let tag: Tag = persistance.create(Tag.self)
            
            tag.id = UUID()
            tag.title = title
            tag.color = nextColor
            tag.tasks = []
            
            return tag
        }
    }
    
    public func update(_ tag: Tag, with attributes: [Attributes : Any]) {
        if let color = attributes[.color] as? Int64 {
            tag.color = color
        }
        if let dates = attributes[.dates] as? [Date] {
            tag.dates = dates
        }
        if let dueDate = attributes[.dueDate] as? Date {
            tag.dueDate = dueDate
        }
        if let id = attributes[.id] as? UUID {
            tag.id = id
        }
        if let title = attributes[.title] as? String {
            tag.title = title
        }
        if let tasks = attributes[.tasks] as? [Task] {
            tag.tasks = NSSet(array: tasks)
        }
    }
    
    // The attributes of the Tag class, mapped according to CoreData
    public enum Attributes {
        case color
        case dates
        case dueDate
        case id
        case title
        case tasks
    }
}

// MARK: - TagPersistenceDelegate Extension

extension TagModel: TagsPersistenceDelegate {
    
    func persistence(_ persistence: Persistence, didInsertTags tags: [Tag]) {
        for tag in tags {
            guard !self.tags.contains(tag) else { continue }
            self.tags.append(tag)
        }
        self.didUpdateTags.onNext(self.tags)
    }
    
    func persistence(_ persistence: Persistence, didUpdateTags tags: [Tag]) {
        for tag in tags {
            guard let index = self.tags.index(of: tag) else { continue }
            self.tags[index] = tag
        }
        self.didUpdateTags.onNext(self.tags)
    }
    
    func persistence(_ persistence: Persistence, didDeleteTags tags: [Tag]) {
        for tag in tags {
            guard let index = self.tags.index(of: tag) else { continue }
            self.tags.remove(at: index)
        }
        self.didUpdateTags.onNext(self.tags)
    }
}
