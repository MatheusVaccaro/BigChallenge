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
import ReefKit

class TagCreationFrameViewModel: CreationFrameViewModelProtocol {
    
    fileprivate var tagModel: TagModel
    fileprivate var tagTitle: String? {
        didSet {
            doneButtonObservable.onNext(shouldEnableDoneButton)
        }
    }
    fileprivate var tagColorIndex: Int?
    fileprivate var tagRegion: CLCircularRegion?
    fileprivate var tagArriving: Bool?
    fileprivate var tagDueTimeOfDay: DateComponents?
    fileprivate var tagDueDate: DateComponents?
    fileprivate var tagFrequency: NotificationOptions.Frequency?
    
    var tag: Tag?
    
    private var tagAttributes: [TagAttributes : Any] {
        var attributes: [TagAttributes : Any] = [:]
        
        if let tagTitle = tagTitle { attributes[.title] = tagTitle }
        if let colorIndex = tagColorIndex { attributes[.colorIndex] = Int64(colorIndex) }
        if let tagArriving = tagArriving { attributes[.arriving] = tagArriving }
        if let tagRegion = tagRegion { attributes[.region] = tagRegion }
        
        if let tagDueDate = tagDueDate,
            let tagDueTimeOfDay = tagDueTimeOfDay,
            let date = Calendar.current.combine(date: tagDueDate, andTimeOfDay: tagDueTimeOfDay) {
            attributes[.dueDate] = date
        }
        
        return attributes
    }
    
    var canCreateTag: Bool {
        guard tagTitle != nil else { return false }
        return true
    }
    
    let doneButtonObservable: BehaviorSubject<Bool>
    
    weak var delegate: CreationFrameViewModelDelegate?

    init(mainInfoViewModel: NewTagViewModel,
         detailViewModel: MoreOptionsViewModel,
         tagModel: TagModel) {
        self.tagModel = tagModel
        doneButtonObservable = BehaviorSubject<Bool>(value: false)
        mainInfoViewModel.outputDelegate = self
        detailViewModel.delegate = self
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapSaveButton() {
        if tag != nil {
            updateTag()
        } else {
            createTagIfPossible()
        }
        delegate?.didTapSaveButton()
    }
    
    private func createTagIfPossible() {
        guard canCreateTag else { return }
        let _ = tagModel.createTag(with: tagAttributes)
    }
    
    private func updateTag() {
        guard let tag = tag else { return }
        tagModel.update(tag, with: tagAttributes)
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
}

extension TagCreationFrameViewModel: MoreOptionsViewModelDelegate {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool) {
        tagRegion = location
        tagArriving = arriving
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents) {
        tagDueDate = date
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectTimeOfDay timeOfDay: DateComponents) {
        tagDueTimeOfDay = timeOfDay
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        tagFrequency = frequency
    }
}
