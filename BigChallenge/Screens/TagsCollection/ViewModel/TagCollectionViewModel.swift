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
    
    init(model: TagModel, filtering: Bool) {
        self.model = model
        self.tags = model.tags
        self.selectedTags = []
        
        tagsObservable = BehaviorSubject<[Tag]>(value: tags)
        selectedTagsObservable = BehaviorSubject<[Tag]>(value: [])
        selectedTagEvent = PublishSubject<Tag>()
        
        subscribeToSelectedTag(filtering: filtering)
        subscribeToModel()
    }
    
    func tagCollectionCellViewModel(for tag: Tag) -> TagCollectionViewCellViewModel {
        return TagCollectionViewCellViewModel(with: tag)
    }
    
    fileprivate func subscribeToSelectedTag(filtering: Bool) {
        selectedTagEvent
            .subscribe { event in
                guard let tag = event.element else { return }
            
                if let index = self.selectedTags.index(of: tag) {
                    self.selectedTags.remove(at: index)
                } else { self.selectedTags.append(tag) }

                self.selectedTagsObservable.onNext(self.selectedTags)
                
                if filtering {
                    self.tags = self.model.tags.filter {
                        let ans = self.selectedTags.isEmpty ||
                            self.selectedTags.contains($0) ||
                            !$0.tasks!.allObjects.isEmpty
                        print("\(ans) for \($0.title!)")
                        return ans
                    }
                    
                    self.tagsObservable.onNext(self.tags)
                }
            }.disposed(by: disposeBag)
    }
    
    fileprivate func subscribeToModel() {
        model.didUpdateTags
            .subscribe {
            self.tags = $0.element!
            print("updated tags: \(self.tags.map {$0.title!})")
            self.tagsObservable.onNext(self.tags)
            }.disposed(by: disposeBag)
    }
    
}
