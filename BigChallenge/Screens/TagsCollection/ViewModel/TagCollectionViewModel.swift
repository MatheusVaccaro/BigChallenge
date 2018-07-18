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
    
    private(set) var tags: [Tag]
    private(set) var selectedTags: [Tag]
    private(set) var selectedTagEvent: PublishSubject<Tag>

    private let disposeBag = DisposeBag()
    private var model: TagModel
    
    init(model: TagModel) {
        self.model = model
        self.tags = model.tags
        self.selectedTags = []
        
        tagsObservable = BehaviorSubject<[Tag]>(value: tags)
        selectedTagsObservable = BehaviorSubject<[Tag]>(value: [])
        selectedTagEvent = PublishSubject<Tag>()
        
        selectedTagEvent.subscribe { event in
            guard let tag = event.element else { return }
            
            if let index = self.selectedTags.index(of: tag) {
                self.selectedTags.remove(at: index)
            } else { self.selectedTags.append(tag) }
            
            //TODO: remove unecessary tags here (by looking at existing tasks)
            self.selectedTagsObservable.onNext(self.selectedTags)
        }.disposed(by: disposeBag)
        
        model.didUpdateTags = {
            self.tags = $0
            self.tagsObservable.onNext(self.tags)
        }
    }
    
    func tagCollectionCellViewModel(for tag: Tag) -> TagCollectionViewCellViewModel {
        return TagCollectionViewCellViewModel(with: tag)
    }
    
}
