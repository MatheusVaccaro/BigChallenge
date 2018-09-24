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
    func shouldPresentViewForLocationInput()
    func shouldPresentViewForDateInput()
}

class TagCreationViewModel {
    weak var delegate: TagCreationDelegate?
    
    fileprivate var model: TagModel
    fileprivate var attributes: [TagAttributes: Any] = [:]
    fileprivate let moreOptionsViewModel: MoreOptionsViewModel
//    fileprivate let newTagViewModel: NewTagViewModel text view
    
    init(tagModel: TagModel, moreOptionsViewModel: MoreOptionsViewModel) {
        self.model = tagModel
        self.moreOptionsViewModel = moreOptionsViewModel
    }
}
