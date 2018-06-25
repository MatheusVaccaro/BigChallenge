//
//  localizationKeys.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 25/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension String {
    static let newTaskCellPlaceholder =
        NSLocalizedString("newTaskTitle", comment: "placeholder title for a new task")
    static let newTaskDone =
        NSLocalizedString("newTaskDone", comment: "the done button to create the task")
    static let newTaskCancel =
        NSLocalizedString("newTaskCancel", comment: "cancel button to cancel editing task")
    static let newTaskScreenTitleEditing =
        NSLocalizedString("newTaskScreenTitleEditing", comment: "screen title when editing task")
    static let newTaskScreenTitleCreating =
        NSLocalizedString("newTaskScreenTitleCreating", comment: "screen title when creating task")
    static let newTaskDeleteTask =
        NSLocalizedString("newTaskDeleteTask", comment: "button used to delete task")
    static let taskListScreenTitle =
        NSLocalizedString("taskListScreenTitle", comment: "title of tasklist tableView screen")
    static let taskCellComplete =
        NSLocalizedString("taskCellComplete", comment: "completed cell status")
    static let taskCellIncomplete =
        NSLocalizedString("taskCellIncomplete", comment: "incomplete cell status")
}
