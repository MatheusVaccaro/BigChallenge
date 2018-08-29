//
//  TagCollectionViewModel.swift
//  Reef
//
//  Created by Max Zorzetti on 22/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit
import RxSwift

protocol TagCollectionViewModelDelegate: class {
    func willUpdate(tag: Tag)
}

protocol TagCollectionViewModel: class {
    var tagsObservable: BehaviorSubject<[Tag]> { get set }
    var selectedTagsObservable: BehaviorSubject<[Tag]> { get set }
    var selectedTagEvent: PublishSubject<Tag> { get }
    var presentingActionSheet: Bool { get set }
    
    var tags: [Tag] { get }
    var filteredTags: [Tag] { get }
    var selectedTags: [Tag] { get }
    var filtering: Bool { get set }
    
    var updateActionTitle: String { get }
    var deleteActionTitle: String { get }
    var cancelActionTitle: String { get }
    
    var delegate: TagCollectionViewModelDelegate? { get set }
    
    init(model: TagModel, filtering: Bool, selectedTags: [Tag])
    
    func tagCollectionCellViewModel(for tag: Tag) -> TagCollectionViewCellViewModel
    
    func delete(tag: Tag)
    
    func update(tag: Tag)
    
    func sortMostTasksIn(_ tags: [Tag]) -> [Tag]
    
    func removeBigTitleTag(_ tags: [Tag]) -> [Tag]
}
