//
//  NewTaskViewModelProtocol.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol NewTaskViewModelProtocol {
    
    var taskTitleText: String? { get set }
    var selectedTags: [Tag] { get set }
    var taskNotesText: String? { get set }
    var userActivity: NSUserActivity { get }
    
    func didTapDeleteTaskButton()
    func willAddTag()
    
    func taskTitle() -> String?
    func titleTextFieldPlaceholder() -> String
}
