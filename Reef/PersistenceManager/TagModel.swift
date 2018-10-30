//
//  TagModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import ReefKit

protocol TagModelDelegate: class {
    func tagModel(_ tagModel: TagModel, didInsert tags: [Tag])
    func tagModel(_ tagModel: TagModel, didDelete tags: [Tag])
    func tagModel(_ tagModel: TagModel, didUpdate tags: [Tag])
}

public class TagModel {
    
    static func region(of tag: Tag) -> CLCircularRegion? {
        guard let data = tag.locationData else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? CLCircularRegion
    }
    
    // MARK: - Properties
    
    weak var delegate: TagModelDelegate?
    var nextColor: Int64 {
        return reefKit.nextColor
    }
    
    private(set) public var tags: [Tag]
//    private let persistance: Persistence
    private let reefKit: ReefKit
    // MARK: - TagModel Lifecyce
    
    init(reefKit: ReefKit) {
        self.reefKit = reefKit
//        self.persistance = reefKit.persistence
        self.tags = []
        
        reefKit.tagsDelegate = self
        reefKit.fetchTags {
            self.tags = $0
            self.delegate?.tagModel(self, didInsert: self.tags)
        }
    }
    
    // MARK: - CRUD Methods
    public func save(_ tag: Tag) {
        if !tags.contains(tag) { tags.append(tag) }
        reefKit.save(tag) // delegate manages the array
    }
    
    public func save(_ tags: [Tag]) {
        reefKit.save(tags)
    }
    
    public func delete(object: Tag) {
        guard tags.contains(object) else { print("could not delete \(object) "); return }
        reefKit.delete(object) // delegate manages the array
    }
    
    public func createTag(with attributes: [TagAttributes : Any]) -> Tag {
        let title = attributes[.title] as? String ?? ""
        if let tag = (tags.first { $0.title == title }) {
            return tag
        } else {
            let tag = reefKit.createTag(with: attributes)
            return tag
        }
    }
    
    public func update(_ tag: Tag, with attributes: [TagAttributes : Any]) {
        reefKit.update(tag, with: attributes)
    }
}

// MARK: - TagPersistenceDelegate Extension

extension TagModel: ReefTagDelegate {
    public func reef(_ reefKit: ReefKit, didInsertTags tags: [Tag]) {
        for tag in tags {
            guard !self.tags.contains(tag) else { continue }
            self.tags.append(tag)
        }
        delegate?.tagModel(self, didInsert: tags)
    }
    
    public func reef(_ reefKit: ReefKit, didUpdateTags tags: [Tag]) {
        for tag in tags {
            guard let index = self.tags.index(of: tag) else { continue }
            self.tags[index] = tag
        }
        delegate?.tagModel(self, didUpdate: tags)
    }
    
    public func reef(_ reefKit: ReefKit, didDeleteTags tags: [Tag]) {
        for tag in tags {
            guard let index = self.tags.index(of: tag) else { continue }
            self.tags.remove(at: index)
        }
        delegate?.tagModel(self, didDelete: tags)
    }
}
