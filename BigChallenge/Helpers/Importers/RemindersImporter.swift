//
//  RemindersImporter.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 04/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import EventKit

public class RemindersImporter {
    
    private let taskModel: TaskModel
    private let tagModel: TagModel
    private static let remindersDB = CommReminders()
    
    init(taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
    }
    
    func importFromReminders() {
        RemindersImporter.remindersDB.fetchAllReminders { reminders in
            for reminder in reminders! where !reminder.isCompleted {
                self.createTask(from: reminder)
            }
        }
    }
    
    private func createTask(from reminder: EKReminder) {
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
    
    public func exportToReminders() {
        do {
            for task in taskModel.fetchAll() {
                RemindersImporter.remindersDB.save(task: task, commit: false)
                try RemindersImporter.remindersDB.store.commit()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    public static func save(task: Task) {
        remindersDB.save(task: task)
    }
}
