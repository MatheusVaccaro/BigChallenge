//
//  TagCollection.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TagCollectionViewModel {
    
    var tagsObservable: BehaviorSubject<[Tag]>
    var selectedTagsObservable: BehaviorSubject<[Tag]>
    
    private var model: TagModel
    private(set) var tags: [Tag]
    private(set) var selectedTags: [Tag]
    
    init(model: TagModel) {
        self.model = model
        self.tags = model.tags
        self.selectedTags = []
        
        tagsObservable = BehaviorSubject<[Tag]>(value: tags)
        selectedTagsObservable = BehaviorSubject<[Tag]>(value: [])
        
        model.didUpdateTags = {
            self.tags = $0
            self.tagsObservable.onNext(self.tags)
        }
    }
    
    func tagCollectionCellViewModel(for tag: Tag) -> TagCollectionViewCellViewModel {
        return TagCollectionViewCellViewModel(with: tag)
    }
    
}
