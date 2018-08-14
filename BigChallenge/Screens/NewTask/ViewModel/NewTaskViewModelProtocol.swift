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
    var userActivity: NSUserActivity { get }
    
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func didTapDeleteTaskButton()
    
    func taskTitle() -> String?
    func titleTextFieldPlaceholder() -> String
    
}
