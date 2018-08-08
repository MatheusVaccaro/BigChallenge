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
    private(set) var selectedTagEvent: PublishSubject<Tag>
    
    private(set) var tags: [Tag]
    private(set) var filteredTags: [Tag]
    private(set) var selectedTags: [Tag]
    let filtering: Bool
    
    private let disposeBag = DisposeBag()
    private var model: TagModel
    
    let alertControllerTitle = Strings.Tag.CollectionScreen.alertControllerTitle
    let alertControllerMessage = Strings.Tag.CollectionScreen.alertControllerMessage
    let deleteActionTitle = Strings.Tag.CollectionScreen.deleteActionTitle
    let cancelActionTitle = Strings.Tag.CollectionScreen.cancelActionTitle
    
    init(model: TagModel, filtering: Bool, selectedTags: [Tag]) {
        self.model = model
        self.tags = model.tags
        self.selectedTags = []
        self.filteredTags = self.tags
        self.filtering = filtering
        
        tagsObservable = BehaviorSubject<[Tag]>(value: tags)
        selectedTagsObservable = BehaviorSubject<[Tag]>(value: selectedTags)
        selectedTagEvent = PublishSubject<Tag>()
        
        subscribeToSelectedTag(filtering: filtering)
        subscribeToModel()
        for tag in selectedTags { selectedTagEvent.onNext(tag) }
    }
    
    func tagCollectionCellViewModel(for tag: Tag) -> TagCollectionViewCellViewModel {
        return TagCollectionViewCellViewModel(with: tag)
    }
    
    func unSelectBigTitle() {
        if let tag = selectedTags.first {
            selectedTagEvent.onNext(tag)
        }
    }
    
    func delete(tag: Tag) {
        model.delete(object: tag)
    }
    
    func sortMostTasksIn(_ tags: [Tag]) -> [Tag] {
        return tags.sorted {
            let completedTasks1 = ($0.tasks!.allObjects as! [Task]).filter { !$0.isCompleted }
            let completedTasks2 = ($1.tasks!.allObjects as! [Task]).filter { !$0.isCompleted }
            
            return completedTasks1.count > completedTasks2.count
        }
    }
    
    func removeBigTitleTag(_ tags: [Tag]) -> [Tag] {
        return tags.filter { selectedTags.isEmpty ? true : selectedTags.first != $0 }
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
                    self.filterTags(with: tag)
                }
            }.disposed(by: disposeBag)
    }
    
    fileprivate func subscribeToModel() {
        model.didUpdateTags
            .subscribe {
                guard self.tags != $0.element else { return }
                self.tags = $0.element!
                self.filteredTags = self.tags
                
                print("updated tags: \(self.tags.map {$0.title!})")
                self.tagsObservable.onNext(self.filteredTags)
            }.disposed(by: disposeBag)
    }

    fileprivate func filterTags(with tag: Tag) {
        filteredTags = model.tags.filter {
            return (selectedTags.isEmpty ||                          //no tag is selected, or
                selectedTags.contains($0) ||                        //tag is selected, or
                !(($0.tasks!.allObjects as! [Task])                 //tag has uncompleted tasks in common
                    .filter { !$0.isCompleted && $0.tags!.contains(tag) }).isEmpty)
        }
        tagsObservable.onNext(filteredTags)
    }
}
