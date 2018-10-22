//
//  TagCollection.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol TagCollectionViewModelDelegate: class {
    func didClickUpdate(tag: Tag)
    func didclickAddTag()
    func didUpdateSelectedTags(_ selectedTags: [Tag])
}

protocol TagCollectionViewModelUIDelegate: class {
    func shouldDelete(at indexPath: [IndexPath])
    func shouldUpdate(at indexPath: [IndexPath])
    func shouldInsert(at indexPath: [IndexPath])
    func shouldUpdate()
}

struct Item {
    var tag: Tag?
}

class TagCollectionViewModel {
    
    var presentingActionSheet: Bool = false
    
    private(set) var filteredTags: [Tag]
    var selectedTags: [Tag]
    
    var filtering: Bool {
        didSet {
            filterTags(with: [])
        }
    }
    
    private var model: TagModel
    
    let updateActionTitle = Strings.General.editActionTitle
    let deleteActionTitle = Strings.General.deleteActionTitle
    let cancelActionTitle = Strings.General.cancelActionTitle
    
    weak var delegate: TagCollectionViewModelDelegate?
    weak var uiDelegate: TagCollectionViewModelUIDelegate?
    
    
    required init(model: TagModel, filtering: Bool, selectedTags: [Tag]) {
        self.model = model
        self.selectedTags = selectedTags
        self.filteredTags = model.tags
        self.filtering = filtering

        
        model.delegate = self
    }
    
    func tag(for indexPath: IndexPath) -> Tag? {
        if filteredTags.indices.contains(indexPath.row) {
            return filteredTags[indexPath.row]
        } else {
            return nil
        }
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
        if filtering {
            filterTags(with: selectedTags)
            uiDelegate?.shouldUpdate()
        }
        delegate?.didUpdateSelectedTags(selectedTags)
    }
    
    fileprivate func filterTags(with tags: [Tag]) {
        //no tag is selected, or
        //tag is selected, or
        //tag has uncompleted tasks in common
        
        if tags.isEmpty {
            filteredTags = model.tags
        } else {
            filteredTags =
                model.tags
                    .filter { tags.contains($0) || $0.hasTagsInCommonWith(tags) }
        }
        
        uiDelegate?.shouldUpdate()
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

extension TagCollectionViewModel: TagModelDelegate {
    func tagModel(_ tagModel: TagModel, didInsert tags: [Tag]) {
        for tag in tags {
            filteredTags.append(tag)
            selectedTags.append(tag)
            let indexPath = IndexPath(row: filteredTags.count-1, section: 0)
            delegate?.didUpdateSelectedTags(selectedTags)
            uiDelegate?.shouldInsert(at: [indexPath])
        }
    }
    
    func tagModel(_ tagModel: TagModel, didDelete tags: [Tag]) {
        for tag in tags {
            if let index = selectedTags.index(of: tag) {
                selectedTags.remove(at: index)
            }
            if let index = filteredTags.index(of: tag) {
                filteredTags.remove(at: index)

                let indexPath = IndexPath(row: index, section: 0)
                delegate?.didUpdateSelectedTags(selectedTags)
                uiDelegate?.shouldDelete(at: [indexPath])
            }
        }
    }
    
    func tagModel(_ tagModel: TagModel, didUpdate tags: [Tag]) {
        var indexes: [IndexPath] = []
        
        for tag in tags {
            if let row = filteredTags.index(of: tag) {
                indexes.append(IndexPath(row: row, section: 0))
            }
        }
        
        uiDelegate?.shouldUpdate(at: indexes)
    }
}

//fileprivate func subscribeToModel() {
//    self.tags = $0.element!
//    self.filteredTags = self.tags
//
//    // remove selected tags from array
//    for tag in self.selectedTags where !self.tags.contains(tag) {
//        let index = self.selectedTags.index(of: tag)!
//        self.selectedTags.remove(at: index)
//    }
//    
//    print("updated tags: \(self.tags.map {$0.title!})")
//
//    if self.filtering { self.filterTags(with: self.selectedTags) }
//
//    self.delegate?.didUpdate(self.selectedTags)
//    self.tagsObservable.onNext(self.filteredTags)
//}

