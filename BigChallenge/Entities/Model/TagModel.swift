//
//  TagModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift
import Crashlytics

protocol TagModelDelegate: class {
    func tagModel(_ tagModel: TagModel, didCreate tag: Tag)
    func tagModel(_ tagModel: TagModel, didUpdate tag: Tag, with attributes: [TagModel.Attributes: Any])
}

extension TagModelDelegate {
    func tagModel(_ tagModel: TagModel, didCreate tag: Tag) { }
    func tagModel(_ tagModel: TagModel, didUpdate tag: Tag, with attributes: [TagModel.Attributes: Any]) { }
}

public class TagModel {
    
    static func region(of tag: Tag) -> CLCircularRegion? {
        guard let data = tag.regionData else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? CLCircularRegion
    }
    
    // MARK: - Properties
    
    weak var delegate: TagModelDelegate?
    
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
            Answers.logCustomEvent(withName: "fetched tags", customAttributes: [
                "numberOfTags" : tags.count,
                "numberOfTasksPerTag" : tags.map { (($0.tasks!.allObjects as! [Task]).filter { !$0.isCompleted }).count }
                ])
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
        NotificationManager.removeAllNotifications(from: object)
        persistance.delete(object) // delegate manages the array
    }
    
    public func createTag(with attributes: [Attributes : Any]) -> Tag {
        let title = attributes[.title] as? String ?? ""
        if let tag = (tags.first { $0.title == title }) {
            return tag
        } else {
            let tag = persistance.create(Tag.self)
            
            let colorIndex = attributes[.colorIndex] as? Int64 ?? nextColor
            let dates = attributes[.dates] as? [Date] ?? []
            let id = attributes[.id] as? UUID ?? UUID()
            let tasks = attributes[.tasks] as? [Task] ?? []
            let arriving = attributes[.arriving] as? Bool ?? false
            
            tag.colorIndex = colorIndex
            tag.dates = dates
            tag.id = id
            tag.title = title
            tag.tasks = NSSet(array: tasks)
            
            if let dueDate = attributes[.dueDate] as? Date {
                tag.dueDate = dueDate
            }
            if let region = attributes[.region] as? CLCircularRegion {
                let regionData =
                    NSKeyedArchiver.archivedData(withRootObject: region)
                tag.regionData = regionData
                tag.arriving = arriving
            }
            
            return tag
        }
    }
    
    public func update(_ tag: Tag, with attributes: [Attributes : Any]) {
        if let color = attributes[.colorIndex] as? Int64 {
            tag.colorIndex = color
        }
        if let dates = attributes[.dates] as? [Date] {
            tag.dates = dates
            NotificationManager.updateTagNotifications(for: tag)
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
        if let colorIndex = attributes[.colorIndex] as? Int64 {
            tag.colorIndex = colorIndex
        }
        if let arriving = attributes[.arriving] as? Bool {
            tag.arriving = arriving
        }
        if let region = attributes[.region] as? CLCircularRegion {
            let regionData = NSKeyedArchiver.archivedData(withRootObject: region)
            tag.regionData = regionData
        }
        
        persistance.save()
        delegate?.tagModel(self, didUpdate: tag, with: attributes)
    }
    
    // The attributes of the Tag class, mapped according to CoreData
    public enum Attributes {
        case colorIndex
        case dates
        case dueDate
        case id
        case title
        case tasks
        case region
        case arriving
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
