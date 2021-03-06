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
    func viewDidLoad()
    func didAddTag()
    func shouldPresent(viewModel: IconCellPresentable)
}

class TagCreationViewModel {
    weak var delegate: TagCreationDelegate?
    
    fileprivate var model: TagModel
    fileprivate var tag: Tag?
    fileprivate var tagInformation: TagInformation = [:]
    
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
            model.save(model.createTag(with: tagInformation))
        } else {
            model.update(tag!, with: tagInformation)
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
        tagInformation[.title] = title
        saveTag()
    }
}

extension TagCreationViewModel: AddTagColorsViewModelDelegate {
    func addTagColorsViewModel(_ addTagColorsViewModel: AddTagColorsViewModel, didUpdateColorIndex colorIndex: Int64) {
        tagInformation[.colorIndex] = colorIndex
    }
}

extension TagCreationViewModel: AddTagDetailsViewModelDelegate {
    func privateTagViewModel(_ privateTagViewModel: PrivateTagViewModel, didActivate: Bool) {
        tagInformation[.requiresAuthentication] = didActivate
    }
    
    func shouldPresent(viewModel: IconCellPresentable) {
        delegate?.shouldPresent(viewModel: viewModel)
    }
    
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion?,
                       named: String?,
                       arriving: Bool) {
        
        tagInformation[.location] = location
        tagInformation[.isArrivingLocation] = arriving
        if let name = named {
            tagInformation[.locationName] = name
        }
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: Date?) {
        tagInformation[.dueDate] = date
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        
    }
}
