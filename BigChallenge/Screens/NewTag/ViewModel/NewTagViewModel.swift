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
    private var tag: Tag?
    var tagTitleTextField: String?
    
    weak var delegate: NewTagViewModelDelegate?
    
    init(tag: Tag?, isEditing: Bool, model: TagModel) {
        self.isEditing = isEditing
        self.model = model
        self.tag = tag
    }
    
    func numberOfSections() -> Int {
        if isEditing {
            return 2
        } else {
            return 1
        }
    }
    
    func numberOfRowsInSection() -> Int {
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
    
    func tagTitle() -> String? {
        return tag?.title
    }
    
    // MARK: - Strings
    func titleTextFieldPlaceholder() -> String {
        return Strings.Tag.CreationScreen.tagTitlePlaceholder
    }
    
    func doneItemTitle() -> String {
        return Strings.Tag.CreationScreen.doneButton
    }
    
    func cancelItemTitle() -> String {
        return Strings.Tag.CreationScreen.cancelButton
    }
    
    func navigationItemTitle() -> String {
        var ans: String = ""
        if isEditing {
            ans = Strings.Tag.EditScreen.title
        } else {
            ans = Strings.Tag.CreationScreen.title
        }
        return ans
    }
    
    func deleteButtonTitle() -> String {
        return Strings.Tag.EditScreen.deleteButton
    }
}

// TODO: Use correct protocol. This extension only exists because currently NewTag is reusing NewTask's viewcontroller
extension NewTagViewModel: NewTaskViewModelProtocol {
    var taskTitleTextField: String? {
        get {
            return tagTitleTextField
        }
        set {
            tagTitleTextField = taskTitleTextField
        }
    }
    
    func didTapDeleteTaskButton() {
        didTapDeleteTagButton()
    }
    
    func taskTitle() -> String? {
        return tagTitle()
    }
}
