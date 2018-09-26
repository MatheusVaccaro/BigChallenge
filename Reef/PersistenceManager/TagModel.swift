//
//  TagModel.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 19/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import ReefKit

protocol TagModelDelegate: class {
    func tagModel(_ tagModel: TagModel, didCreate tag: Tag)
    func tagModel(_ tagModel: TagModel, didUpdate tag: Tag, with attributes: [TagAttributes: Any])
}

extension TagModelDelegate {
    func tagModel(_ tagModel: TagModel, didCreate tag: Tag) { }
    func tagModel(_ tagModel: TagModel, didUpdate tag: Tag, with attributes: [TagAttributes: Any]) { }
}

public class TagModel {
    
    static func region(of tag: Tag) -> CLCircularRegion? {
        guard let data = tag.locationData else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? CLCircularRegion
    }
    
    // MARK: - Properties
    
    weak var delegate: TagModelDelegate?
    
    private(set) var didUpdateTags: BehaviorSubject<[Tag]>
    private(set) public var tags: [Tag]
//    private let persistance: Persistence
    private let reefKit: ReefKit
    // MARK: - TagModel Lifecyce
    
    init(reefKit: ReefKit) {
        self.reefKit = reefKit
//        self.persistance = reefKit.persistence
        self.tags = []
        self.didUpdateTags = BehaviorSubject<[Tag]>(value: tags)
        
        reefKit.tagsDelegate = self
        reefKit.fetchTags {
            self.tags = $0
            self.didUpdateTags.onNext(self.tags)
        }
    }
    
    // MARK: - CRUD Methods
    public func save(_ tag: Tag) {
        if !tags.contains(tag) { tags.append(tag) }
        reefKit.save(tag) // delegate manages the array
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
        delegate?.tagModel(self, didUpdate: tag, with: attributes)
    }
}

// MARK: - TagPersistenceDelegate Extension

extension TagModel: ReefTagDelegate {
    public func reef(_ reefKit: ReefKit, didInsertTags tags: [Tag]) {
        for tag in tags {
            guard !self.tags.contains(tag) else { continue }
            self.tags.append(tag)
        }
        self.didUpdateTags.onNext(self.tags)
    }
    
    public func reef(_ reefKit: ReefKit, didUpdateTags tags: [Tag]) {
        for tag in tags {
            guard let index = self.tags.index(of: tag) else { continue }
            self.tags[index] = tag
        }
        self.didUpdateTags.onNext(self.tags)
    }
    
    public func reef(_ reefKit: ReefKit, didDeleteTags tags: [Tag]) {
        for tag in tags {
            guard let index = self.tags.index(of: tag) else { continue }
            self.tags.remove(at: index)
        }
        self.didUpdateTags.onNext(self.tags)
    }
}
