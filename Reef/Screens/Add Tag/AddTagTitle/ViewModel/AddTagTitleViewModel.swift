//
//  AddTagTitleViewModel.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import ReefKit

protocol AddTagTitleViewModelDelegate: class {
    func addTag(_ addTagTitleViewModel: AddTagTitleViewModel,
                createdTag named: String?)
}

class AddTagTitleViewModel {
    weak var delegate: AddTagTitleViewModelDelegate!
    
    func createTagIfPossible(_ text: String) -> Bool {
        if !text.isEmpty {
            delegate.addTag(self, createdTag: text)
            return true
        } else {
            return false
        }
    }
    
    private(set) var tagTitle: String?
    
    func edit(_ tag: Tag) {
        tagTitle = tag.title
    }
}
