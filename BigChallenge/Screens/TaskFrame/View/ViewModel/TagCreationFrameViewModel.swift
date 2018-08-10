//
//  TagCreationFrameViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 10/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class TagCreationFrameViewModel: CreationFrameViewModelProtocol {
    
    fileprivate var tagModel: TagModel

    let doneButtonObservable: BehaviorSubject<Bool>
    
    weak var delegate: CreationFrameViewModelDelegate?

    init(tagModel: TagModel) {
        self.tagModel = tagModel
        doneButtonObservable = BehaviorSubject<Bool>(value: false)
        
    }
    
    func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    func didTapSaveButton() {
        delegate?.didTapSaveButton()
    }
}
