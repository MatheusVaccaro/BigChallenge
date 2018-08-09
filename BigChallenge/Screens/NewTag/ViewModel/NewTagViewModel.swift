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
    
    var tagTitle: String? {
        didSet {
            
        }
    }
    
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
        guard let tagTitle = tagTitle else { return }
        let attributes: [TagModel.Attributes : Any] =
            [.title : tagTitle as Any]
        let tag = model.createTag(with: attributes)
        self.tag = tag
        model.save(tag)
    }
    
    // MARK: - Strings
    func titleTextFieldPlaceholder() -> String {
        return Strings.Task.CreationScreen.taskTitlePlaceholder
    }
}
