//
//  TagCollection.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit
import RxSwift

protocol TagCollectionViewModelDelegate: class {
    func didClickUpdate(tag: Tag)
    func didclickAddTag()
    func didUpdate(_ selectedTags: [Tag])
}

struct Item {
    var tag: Tag?
}

class TagCollectionViewModel {
    
    var tagsObservable: BehaviorSubject<[Tag]>
    var selectedTagsObservable: BehaviorSubject<[Tag]>
    
    var presentingActionSheet: Bool = false
    
    private(set) var tags: [Tag]
    private(set) var filteredTags: [Tag]
    private(set) var selectedTags: [Tag]
    
    var filtering: Bool {
        didSet {
            filterTags(with: [])
        }
    }
    
    private let disposeBag = DisposeBag()
    private var model: TagModel
    
    let updateActionTitle = Strings.General.editActionTitle
    let deleteActionTitle = Strings.General.deleteActionTitle
    let cancelActionTitle = Strings.General.cancelActionTitle
    
    weak var delegate: TagCollectionViewModelDelegate?
    
    required init(model: TagModel, filtering: Bool, selectedTags: [Tag]) {
        self.model = model
        self.tags = model.tags
        self.selectedTags = selectedTags
        self.filteredTags = self.tags
        self.filtering = filtering
        
        tagsObservable = BehaviorSubject<[Tag]>(value: tags)
        selectedTagsObservable = BehaviorSubject<[Tag]>(value: selectedTags)
        
        subscribeToModel()
    }
    
    func tagCollectionCellViewModel(for tag: Tag) -> TagCollectionViewCellViewModel {
        return TagCollectionViewCellViewModel(with: tag)
    }
    
    func delete(tag: Tag) {
        if tag.requiresAuthentication {
            Authentication.authenticate { granted in
                if granted {
                    self.model.delete(object: tag)
                }
                return
            }
        } else {
            model.delete(object: tag)
        }
    }
    
    func update(tag: Tag) {
        if tag.requiresAuthentication {
            Authentication.authenticate { granted in
                if granted {
                    self.delegate?.didClickUpdate(tag: tag)
                }
                return
            }
        } else {
            delegate?.didClickUpdate(tag: tag)
        }
    }
    
    func sortMostTasksIn(_ tags: [Tag]) -> [Tag] {
        return tags.sorted {
            let completedTasks1 = $0.allTasks.filter { !$0.isCompleted }
            let completedTasks2 = $1.allTasks.filter { !$0.isCompleted }
            
            return completedTasks1.count > completedTasks2.count
        }
    }
    
    func shouldAskForAuthentication(with tag: Tag) -> Bool {
        return tag.requiresAuthentication && filtering
    }
    
    func select(_ tag: Tag) {
        if let index = selectedTags.index(of: tag) { selectedTags.remove(at: index) } else {
            selectedTags.append(tag)
        }
        updateAfterTagSelected()
    }
    
    fileprivate func updateAfterTagSelected() {
        if filtering { filterTags(with: selectedTags) }
        selectedTagsObservable.onNext(selectedTags)
        delegate?.didUpdate(selectedTags)
    }
    
    fileprivate func subscribeToModel() {
        model.didUpdateTags
            .subscribe {
                self.tags = $0.element!
                self.filteredTags = self.tags
                
                // remove selected tags from array
                for tag in self.selectedTags where !self.tags.contains(tag) {
                    let index = self.selectedTags.index(of: tag)!
                    self.selectedTags.remove(at: index)
                }
                
                print("updated tags: \(self.tags.map {$0.title!})")
                
                if self.filtering { self.filterTags(with: self.selectedTags) }
                self.selectedTagsObservable.onNext(self.selectedTags)
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
