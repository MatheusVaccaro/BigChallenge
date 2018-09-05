//
//  NewTagViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 16/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import ReefKit

protocol NewTagViewModelDelegate: class {
    func didTapCancelButton()
    func didTapDoneButton()
    func didTapDeleteTagButton()
}

protocol NewTagViewModelOutputDelegate: class {
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateTitle title: String?)
    func newTagViewModel(_ newTagViewModel: NewTagViewModel, didUpdateColorIndex colorIndex: Int?)
}

class NewTagViewModel: NewTagViewModelProtocol {
    
    private let model: TagModel
    private var tag: Tag?
    
    var colorIndex: Int? {
        didSet {
            outputDelegate?.newTagViewModel(self, didUpdateColorIndex: colorIndex)
        }
    }
    var tagTitle: String? {
        didSet {
            outputDelegate?.newTagViewModel(self, didUpdateTitle: tagTitle)
        }
    }
    
    weak var outputDelegate: NewTagViewModelOutputDelegate?
    weak var delegate: NewTagViewModelDelegate?
    
    init(tag: Tag?, model: TagModel) {
        self.model = model
        self.tag = tag
        
        if let tag = tag {
            configureAttributes(from: tag)
        }
        
        print("+++ INIT NewTagViewModel")
    }
    
    deinit {
        print("--- DEINIT NewTagViewModel")
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
        return UIColor.tagColors.count
    }
    
    private func configureAttributes(from tag: Tag) {
        colorIndex = Int(tag.colorIndex)
        tagTitle = tag.title
    }
    
    // MARK: - Strings
    func titleTextFieldPlaceholder() -> String {
        return Strings.Task.CreationScreen.taskTitlePlaceholder
    }
    
    var placeholder: String {
        return titleTextFieldPlaceholder()
    }
}
