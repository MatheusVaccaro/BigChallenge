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
    
    weak var delegate: AddTagColorsViewModelDelegate?
    
    var colorIndex: Int = UIColor.tagColors.startIndex { //TODO: get next index
        didSet {
            delegate?.addTagColorsViewModel(self, didUpdateColorIndex: colorIndex)
        }
    }
    
    func edit(_ tag: Tag) {
        colorIndex = Int(tag.colorIndex)
    }
    
    func numberOfColors() -> Int {
        return UIColor.tagColors.count
    }
}
