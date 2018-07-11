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
    
    public static var instance: RemindersImporter?
    
	private let taskModel: TaskModel
    private let tagModel: TagModel
    private let remindersDB: CommReminders
    
    // Initializes CommReminders and requests access afterwards
    private init(taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
		self.remindersDB = CommReminders()
        
        defer {
            remindersDB.delegate = self
            remindersDB.requestAccess()
        }
    }
    
    // Should be instantiated using this method
    public static func instantiate(taskModel: TaskModel, tagModel: TagModel) {
        guard instance == nil else { return } // Forces the class to have one instance only
        
        self.instance = RemindersImporter(taskModel: taskModel, tagModel: tagModel)
    }
    
    // Fetch all reminders; convert them to Tasks and Tags; save these afterwards
    func importFromReminders() {
        remindersDB.fetchAllReminders { reminders in
            for reminder in reminders! where !reminder.isCompleted {
                
                let (task, tag) = self.convertTaskAndTag(from: reminder)
                
                self.taskModel.save(object: task)
                self.tagModel.save(object: tag)
            }
        }
    }
    
    // Convert a reminder to a Task and a Tag
    private func convertTaskAndTag(from reminder: EKReminder) -> (Task, Tag) {
        let task =
            self.taskModel.createTask(with: reminder.title)
        let tag =
            self.tagModel.createTag(with: reminder.calendar.title)
    
        task.addToTags(tag)
        task.isCompleted = reminder.isCompleted
        task.completionDate = reminder.completionDate
        task.dueDate = reminder.completionDate
        task.creationDate = reminder.creationDate
	
        return (task, tag)
    }
    
    public func exportToReminders() {
        do {
            for task in taskModel.fetchAll() {
                remindersDB.save(task: task, commit: false)
                try remindersDB.store.commit()
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    public func save(task: Task) {
        remindersDB.save(task: task)
    }
}

extension RemindersImporter: CommRemindersDelegate {
    
    func commRemindersDidDetectEventStoreChange(_ commReminders: CommReminders, notification: NSNotification) {
        // TODO Figure out how to fetch the affected reminders without duplicating the whole Reminders Store
        // So far, seems like it is impossible.
    }
    
    func commRemindersWasGrantedAccessToReminders(_ commReminders: CommReminders) {
        // TODO Set persistent flag to avoid importing each time the app launches.
        importFromReminders()
    }
    
    func commRemindersWasDeniedAccessToReminders(_ commReminders: CommReminders, error: Error) {
        // TODO Handle access denial
    }
}
