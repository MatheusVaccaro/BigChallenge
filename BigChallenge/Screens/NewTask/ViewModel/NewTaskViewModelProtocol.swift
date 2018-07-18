//
//  NewTaskViewModelProtocol.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol NewTaskViewModelProtocol {
    
    var taskTitleTextField: String? { get set }
    
    func numberOfSections() -> Int
    func numberOfRowsInSection() -> Int
    func didTapCancelButton()
    func didTapDoneButton()
    func didTapDeleteTaskButton()
    
    func taskTitle() -> String?
    func titleTextFieldPlaceholder() -> String
    func doneItemTitle() -> String
    func cancelItemTitle() -> String
    func navigationItemTitle() -> String
    func deleteButtonTitle() -> String
    
}
