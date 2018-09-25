//
//  AddTagColorsViewModel.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import ReefKit

protocol AddTagColorsViewModelDelegate: class {
    func addTagColorsViewModel(_ addTagColorsViewModel: AddTagColorsViewModel, didUpdateColorIndex colorIndex: Int?)
}

class AddTagColorsViewModel {
    
    private let model: TagModel
    private var tag: Tag?
    
    weak var delegate: AddTagColorsViewModelDelegate?
    
    var colorIndex: Int? {
        didSet {
            outputDelegate?.addTagColorsViewModel(self, didUpdateColorIndex: colorIndex)
        }
    }
    
    init(tag: Tag?, model: TagModel) {
        self.model = model
        self.tag = tag
    }
    
    func numberOfColors() -> Int {
        return UIColor.tagColors.count
    }
}
