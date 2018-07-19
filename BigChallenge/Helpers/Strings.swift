//
//  localizationKeys.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 25/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

//swiftlint:disable nesting
//swiftlint:disable type_name

import Foundation

struct Strings {
    
    struct Task {
        
        struct CreationScreen {
            static let title =
                NSLocalizedString("newTaskScreenTitleCreating", comment: "screen title when creating task")
            static let doneButton =
                NSLocalizedString("newTaskDone", comment: "the done button to create the task")
            static let cancelButton =
                NSLocalizedString("newTaskCancel", comment: "cancel button to cancel editing task")
            static let taskTitlePlaceholder =
                NSLocalizedString("newTaskTitle", comment: "placeholder title for a new task")
        }
        
        struct EditScreen {
            static let title =
                NSLocalizedString("newTaskScreenTitleEditing", comment: "screen title when editing task")
            static let deleteButton =
                NSLocalizedString("newTaskDeleteTask", comment: "button used to delete task")
        }
        
        struct ListScreen {
            static let title =
                NSLocalizedString("taskListScreenTitle", comment: "title of tasklist tableView screen")
        }
        
        struct Cell {
            static let complete =
                NSLocalizedString("taskCellComplete", comment: "completed cell status")
            static let incomplete =
                NSLocalizedString("taskCellIncomplete", comment: "incomplete cell status")
        }
        
    }
    
    struct Tag {
        
        struct CreationScreen {
            static let title =
                NSLocalizedString("newTagScreenTitleCreating", comment: "screen title when creating tag")
            static let doneButton =
                NSLocalizedString("newTagDone", comment: "the done button to create the tag")
            static let cancelButton =
                NSLocalizedString("newTagCancel", comment: "cancel button to cancel editing tag")
            static let tagTitlePlaceholder =
                NSLocalizedString("newTagTitle", comment: "placeholder title for a new tag")
        }
        
        struct EditScreen {
            static let title =
                NSLocalizedString("newTagScreenTitleEditing", comment: "screen title when editing tag")
            static let deleteButton =
                NSLocalizedString("newTagDeleteTag", comment: "button used to delete tag")
        }
        
        struct CollectionScreen {
            static let title =
                NSLocalizedString("CollectionScreenTitle", comment: "screen title when on \"all tags\" screen")
        }
    }
}
