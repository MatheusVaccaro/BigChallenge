//
//  NewTagViewModelProtocol.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol NewTagViewModelProtocol {
    
    var tagTitleTextField: String? { get set }
    
    func numberOfSections() -> Int
    func numberOfRowsInSection() -> Int
    func didTapCancelButton()
    func didTapDoneButton()
    func didTapDeleteTagButton()
    
    func tagTitle() -> String?
    func titleTextFieldPlaceholder() -> String
    func doneItemTitle() -> String
    func cancelItemTitle() -> String
    func navigationItemTitle() -> String
    func deleteButtonTitle() -> String
    
}
