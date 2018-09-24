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
    func didTapAddTag()
    func shouldPresent(viewModel: IconCellPresentable)
}

class TagCreationViewModel {
    weak var delegate: TagCreationDelegate?
    
    fileprivate var model: TagModel
    fileprivate var attributes: [TagAttributes: Any] = [:]
    fileprivate let addTagDetailsViewModel: AddTagDetailsViewModel
    fileprivate let addTagTitleViewModel: AddTagTitleViewModel
    
    init(tagModel: TagModel, _ addTagDetailsViewModel: AddTagDetailsViewModel, _ addTagTitleViewModel: AddTagTitleViewModel) {
        self.model = tagModel
        self.addTagTitleViewModel = addTagTitleViewModel
        self.addTagDetailsViewModel = addTagDetailsViewModel
        
//        addTagTitleViewModel.delegate = self TODO
        addTagDetailsViewModel.delegate = self
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
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents) {
        attributes[.dueDate] = date
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency) {
//        attributes[.] TODO
    }
}
