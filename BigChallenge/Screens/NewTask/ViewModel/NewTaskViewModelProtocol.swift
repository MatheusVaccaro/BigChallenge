//
//  NewTaskViewModelProtocol.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol NewTaskViewModelProtocol {
    
    var taskTitleText: String? { get set }
    var selectedTags: [Tag] { get set }
    var taskNotesText: String? { get set }
    var dueDate: Date? { get set }
    
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
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
