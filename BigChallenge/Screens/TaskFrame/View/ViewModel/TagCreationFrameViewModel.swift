//
//  TagCreationFrameViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 10/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class TagCreationFrameViewModel: CreationFrameViewModelProtocol {
    
    fileprivate var tagModel: TagModel
    fileprivate var tagTitle: String? {
        didSet {
            doneButtonObservable.onNext(shouldEnableDoneButton)
        }
    }
    fileprivate var tagColorIndex: Int?
    fileprivate var tagLocation: CLLocation?
    
    var tag: Tag?
    
    let doneButtonObservable: BehaviorSubject<Bool>
    
    weak var delegate: CreationFrameViewModelDelegate?

    init(mainInfoViewModel: NewTagViewModel,
         tagModel: TagModel) {
        self.tagModel = tagModel
        doneButtonObservable = BehaviorSubject<Bool>(value: false)
        mainInfoViewModel.outputDelegate = self
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapSaveButton() {
        if let tag = tag {
            updateTag()
        } else {
            createTagIfPossible()
        }
        delegate?.didTapSaveButton()
    }
    
    private func createTagIfPossible() {
        guard let tagTitle = tagTitle else { return }
    
        var attributes: [TagModel.Attributes : Any] = [
            .title : tagTitle as Any
        ]
        
        if let colorIndex = tagColorIndex {
            let int64ColorIndex = Int64(colorIndex)
            attributes[.colorIndex] = int64ColorIndex
        }
        
        let tag = tagModel.createTag(with: attributes)
        tagModel.save(tag)
    }
    
    private func updateTag() {
        guard let tag = tag else { return }
        guard let tagTitle = tagTitle else { return }
        
        var attributes: [TagModel.Attributes : Any] = [
            .title : tagTitle as Any
        ]
        
        if let colorIndex = tagColorIndex {
            let int64ColorIndex = Int64(colorIndex)
            attributes[.colorIndex] = int64ColorIndex
        }
        
        tagModel.update(tag, with: attributes)
    }
    
    private var shouldEnableDoneButton: Bool {
        guard let tagTitle = tagTitle else { return false }
        return !tagTitle.isEmpty
    }
}

extension TagCreationFrameViewModel: NewTagViewModelOutputDelegate {
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateTitle title: String?) {
        tagTitle = title
    }
    
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateColorIndex colorIndex: Int?) {
        tagColorIndex = colorIndex
    }
    
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateLocation location: CLLocation?) {
        tagLocation = location
    }
}
