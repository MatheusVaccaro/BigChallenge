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

protocol TagCollectionViewModelDelegate: class {
    func willUpdate(tag: Tag)
}

class TagCollectionViewModel {
    
    var tagsObservable: BehaviorSubject<[Tag]>
    var selectedTagsObservable: BehaviorSubject<[Tag]>
    private(set) var selectedTagEvent: PublishSubject<Tag>
    
    var presentingActionSheet: Bool = false
    
    private(set) var tags: [Tag]
    private(set) var filteredTags: [Tag]
    private(set) var selectedTags: [Tag]
    var filtering: Bool
    
    private let disposeBag = DisposeBag()
    private var model: TagModel
    
    let updateActionTitle = Strings.Tag.CollectionScreen.updateActionTitle
    let deleteActionTitle = Strings.Tag.CollectionScreen.deleteActionTitle
    let cancelActionTitle = Strings.Tag.CollectionScreen.cancelActionTitle
    
    weak var delegate: TagCollectionViewModelDelegate?
    
    init(model: TagModel, filtering: Bool, selectedTags: [Tag]) {
        self.model = model
        self.tags = model.tags
        self.selectedTags = []
        self.filteredTags = self.tags
        self.filtering = filtering
        
        tagsObservable = BehaviorSubject<[Tag]>(value: tags)
        selectedTagsObservable = BehaviorSubject<[Tag]>(value: selectedTags)
        selectedTagEvent = PublishSubject<Tag>()
        
        subscribeToSelectedTag()
        subscribeToModel()
        for tag in selectedTags { selectedTagEvent.onNext(tag) }
    }
    
    func tagCollectionCellViewModel(for tag: Tag) -> TagCollectionViewCellViewModel {
        return TagCollectionViewCellViewModel(with: tag)
    }
    
    func delete(tag: Tag) {
        model.delete(object: tag)
    }
    
    func update(tag: Tag) {
        delegate?.willUpdate(tag: tag)
    }
    
    func sortMostTasksIn(_ tags: [Tag]) -> [Tag] {
        return tags.sorted {
            let completedTasks1 = $0.allTasks.filter { !$0.isCompleted }
            let completedTasks2 = $1.allTasks.filter { !$0.isCompleted }
            
            return completedTasks1.count > completedTasks2.count
        }
    }
    
    func removeBigTitleTag(_ tags: [Tag]) -> [Tag] {
        return tags.filter { selectedTags.isEmpty ? true : selectedTags.first != $0 }
    }
    
    fileprivate func subscribeToSelectedTag() {
        selectedTagEvent
            .subscribe { event in
                guard let tag = event.element else { return }
            
                if let index = self.selectedTags.index(of: tag) {
                    self.selectedTags.remove(at: index)
                } else { self.selectedTags.append(tag) }

                self.selectedTagsObservable.onNext(self.selectedTags)
                
                if self.filtering {
                    self.filterTags(with: self.selectedTags)
                }
            }.disposed(by: disposeBag)
    }
    
    fileprivate func subscribeToModel() {
        model.didUpdateTags
            .subscribe {
                guard self.tags != $0.element else { return }
                self.tags = $0.element!
                self.filteredTags = self.tags
                
                for tag in self.selectedTags where !self.tags.contains(tag) {
                    let index = self.selectedTags.index(of: tag)!
                    self.selectedTags.remove(at: index)
                    self.selectedTagsObservable.onNext(self.selectedTags)
                }
                
                print("updated tags: \(self.tags.map {$0.title!})")
                self.tagsObservable.onNext(self.filteredTags)
            }.disposed(by: disposeBag)
    }

    fileprivate func filterTags(with tags: [Tag]) {
        //no tag is selected, or
        //tag is selected, or
        //tag has uncompleted tasks in common
        
        if tags.isEmpty {
            filteredTags = self.tags
        } else {
            filteredTags =
                model.tags
                    .filter { tags.contains($0) || $0.hasTagsInCommonWith(tags) }
        }
        
        tagsObservable.onNext(filteredTags)
    }
}

fileprivate extension Tag {
    func hasTagsInCommonWith(_ tags: [Tag]) -> Bool {
        return !(allTasks
            .filter { !$0.isCompleted }
            .filter { Set<Tag>(tags).isSubset(of: $0.allTags) }
            .isEmpty)
    }
}
