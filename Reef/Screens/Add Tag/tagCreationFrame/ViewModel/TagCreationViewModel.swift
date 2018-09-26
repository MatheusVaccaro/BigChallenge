//
//  TagCreationViewModel.swift
//  Reef
//
//  Created by Gabriel Paul on 21/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit
import CoreLocation

protocol TagCreationDelegate: class {
    func didAddTag()
    func shouldPresent(viewModel: IconCellPresentable)
}

class TagCreationViewModel {
    weak var delegate: TagCreationDelegate?
    
    fileprivate var model: TagModel
    fileprivate var tag: Tag?
    fileprivate var attributes: [TagAttributes: Any] = [:]
    
    fileprivate let addTagTitleViewModel: AddTagTitleViewModel
    fileprivate let addTagColorsViewModel: AddTagColorsViewModel
    fileprivate let addTagDetailsViewModel: AddTagDetailsViewModel
    
    init(tagModel: TagModel,
         _ addTagTitleViewModel: AddTagTitleViewModel,
         _ addTagColorsViewModel: AddTagColorsViewModel,
         _ addTagDetailsViewModel: AddTagDetailsViewModel) {
        self.model = tagModel
        
        self.addTagTitleViewModel = addTagTitleViewModel
        self.addTagColorsViewModel = addTagColorsViewModel
        self.addTagDetailsViewModel = addTagDetailsViewModel
        
        addTagTitleViewModel.delegate = self
        addTagColorsViewModel.delegate = self
        addTagDetailsViewModel.delegate = self
    }
    
    func edit(_ tag: Tag?) {
        if let tag = tag {
            self.tag = tag
            addTagTitleViewModel.edit(tag)
            addTagColorsViewModel.edit(tag)
            addTagDetailsViewModel.edit(tag)
        }
    }
    
    func saveTag() {
        if tag == nil {
            model.save(model.createTag(with: attributes))
        } else {
            model.update(tag!, with: attributes)
        }
        
        tag = nil
        delegate?.didAddTag()
    }
    
    func cancelAddTag() {
        delegate?.didAddTag()
    }
}

extension TagCreationViewModel: AddTagTitleViewModelDelegate {
    func addTag(_ addTagTitleViewModel: AddTagTitleViewModel, createdTag title: String?) {
        attributes[.title] = title
        saveTag()
    }
}

extension TagCreationViewModel: AddTagColorsViewModelDelegate {
    func addTagColorsViewModel(_ addTagColorsViewModel: AddTagColorsViewModel, didUpdateColorIndex colorIndex: Int?) {
        attributes[.colorIndex] = colorIndex
    }
}

extension TagCreationViewModel: AddTagDetailsViewModelDelegate {
    func shouldPresent(viewModel: IconCellPresentable) {
        delegate?.shouldPresent(viewModel: viewModel)
    }
    
    func locationInput(_ locationInputViewModel: LocationInputViewModel, didFind location: CLCircularRegion, arriving: Bool) {
        attributes[.region] = location
        attributes[.arriving] = arriving
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: Date) {
        attributes[.dueDate] = date
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency) {
//        attributes[.] TODO
    }
}
