//
//  NewTagViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 16/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

protocol NewTagViewModelDelegate: class {
    func didTapCancelButton()
    func didTapDoneButton()
    func didTapDeleteTagButton()
}

protocol NewTagViewModelOutputDelegate: class {
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateTitle title: String?)
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateColorIndex colorIndex: Int?)
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateLocation location: CLLocation?)
}

class NewTagViewModel: NewTagViewModelProtocol {
    
    private let model: TagModel
    private var isEditing: Bool
    private var tag: Tag? {
        didSet {
            if let colorIndex64 = tag?.colorIndex {
                colorIndex = Int(colorIndex64)
            }
            tagTitle = tag?.title
        }
    }
    
    var colorIndex: Int? {
        didSet {
            outputDelegate?.newTagViewModel(self, didUpdateColorIndex: colorIndex)
        }
    }
    var location: CLLocation? {
        didSet {
            outputDelegate?.newTagViewModel(self, didUpdateLocation: location)
        }
    }
    var tagTitle: String? {
        didSet {
            outputDelegate?.newTagViewModel(self, didUpdateTitle: tagTitle)
        }
    }
    
    weak var outputDelegate: NewTagViewModelOutputDelegate?
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
    
    func didTapDeleteTagButton() {
        delegate?.didTapDeleteTagButton()
        deleteTag()
    }
    
    private func deleteTag() {
        guard let tag = tag else { return }
        model.delete(object: tag)
    }
    
    func numberOfColors() -> Int {
        return TagModel.tagColors.count
    }
    
    // MARK: - Strings
    func titleTextFieldPlaceholder() -> String {
        return Strings.Task.CreationScreen.taskTitlePlaceholder
    }
    
    var placeholder: String {
        return titleTextFieldPlaceholder()
    }
}
