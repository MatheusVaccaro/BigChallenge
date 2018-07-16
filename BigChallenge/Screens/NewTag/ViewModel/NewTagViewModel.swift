//
//  NewTagViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 16/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol NewTagViewModelDelegate: class {
    
    func didTapCancelButton()
    func didTapDoneButton()
    func didTapDeleteTagButton()
    
}

class NewTagViewModel {
    
    private let model: TagModel
    private var isEditing: Bool
    var tag: Tag?
    var tagTitleTextField: String?
    
    weak var delegate: NewTagViewModelDelegate?
    
    init(tag: Tag?, isEditing: Bool, model: TagModel) {
        self.isEditing = isEditing
        self.model = model
        self.tag = tag
    }
    
    var numberOfSections: Int {
        if isEditing {
            return 2
        } else {
            return 1
        }
    }
    
    var numberOfRowsInSection: Int {
        return 1
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapDoneButton() {
        delegate?.didTapDoneButton()
        if isEditing {
            // TODO
        } else {
            createTag()
        }
    }
    
    func didTapDeleteTagButton() {
        delegate?.didTapDeleteTagButton()
        deleteTag()
    }
    
    private func deleteTag() {
        guard let tag = tag else { return }
        model.delete(object: tag)
    }
    
    private func createTag() {
        guard let tagTitle = tagTitleTextField else { return }
        let tag = model.createTag(with: tagTitle)
        self.tag = tag
        model.save(object: tag)
    }
    
    // MARK: - Strings
    let titleTextFieldPlaceHolder = String.newTagCellPlaceholder
    let doneItemTitle = String.newTagDone
    let cancelItemTitle = String.newTagCancel
    
    var navigationItemTitle: String {
        var ans: String = ""
        if isEditing {
            ans = String.newTagScreenTitleEditing
        } else {
            ans = String.newTagScreenTitleCreating
        }
        return ans
    }
    
    var deleteButtonTitle: String {
        return String.newTagDeleteTag
    }
}
