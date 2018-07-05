//
//  RemindersImporter.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 04/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public class RemindersImporter {
    
    private let taskModel: TaskModel
    private let tagModel: TagModel
    
    init(taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
    }
    
    func importFromReminders() {
        CommReminders().fetchAllReminders { reminders in
            for reminder in reminders! {
                
                let task =
                    self.taskModel.createTask(with: reminder.title)
                let tag =
                    self.tagModel.createTag(with: reminder.calendar.title)
                
                task.addToTags(tag)
                task.isCompleted = reminder.isCompleted
                task.completionDate = reminder.completionDate
                task.dueDate = reminder.completionDate
                task.creationDate = reminder.creationDate
                
                self.taskModel.save(object: task)
                self.tagModel.save(object: tag)
            }
        }
    }
}
