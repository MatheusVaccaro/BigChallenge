//
//  AddTagColorsViewModel.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import ReefKit

protocol AddTagColorsViewModelDelegate: class {
    func addTagColorsViewModel(_ addTagColorsViewModel: AddTagColorsViewModel, didUpdateColorIndex colorIndex: Int64)
}

class AddTagColorsViewModel {
    
    weak var delegate: AddTagColorsViewModelDelegate?
    
    var colorIndex: Int64 = Int64(UIColor.tagColors.startIndex) {
        didSet {
            delegate?.addTagColorsViewModel(self, didUpdateColorIndex: colorIndex)
        }
    }
    
    func edit(_ tag: Tag) {
        colorIndex = tag.colorIndex
    }
    
    func numberOfColors() -> Int {
        return UIColor.tagColors.count
    }
}
