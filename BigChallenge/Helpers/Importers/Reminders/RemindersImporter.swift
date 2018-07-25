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
    private let remindersDB: RemindersCommunicator
    
    // Initializes RemindersCommunicator
    private init(taskModel: TaskModel, tagModel: TagModel) {
        self.taskModel = taskModel
        self.tagModel = tagModel
		self.remindersDB = RemindersCommunicator()
        
        defer {
            remindersDB.delegate = self
        }
    }
    
    /**
     Attempts to start the import procedure.
 	*/
    func attemptToImport() {
        remindersDB.requestAccess()
    }
    
    // Should be instantiated using this method
    public static func instantiate(taskModel: TaskModel, tagModel: TagModel) {
        guard instance == nil else { return } // Forces the class to have one instance only
        
        self.instance = RemindersImporter(taskModel: taskModel, tagModel: tagModel)
    }
    
    // Fetch all reminders; convert them to Tasks and Tags; save these afterwards
    func importTasksFromReminders() {
        remindersDB.fetchAllReminders { reminders in
            guard let reminders = reminders else { return }
            
            for reminder in reminders where !self.checkImportStatusForReminder(reminder) {
                
                let (task, tag) = self.convertTaskAndTag(from: reminder)
                
                self.taskModel.save(task)
                self.tagModel.save(object: tag)
            }
        }
    }
    
    /**
     Checks if a reminder has already been imported and converted into a task (i.e. has an equivalent task).
     
     - Parameter reminder: The reminder to check the import status of.
     
     - Returns: ```true``` if the reminder has been imported into a task.
     			```false``` if the reminder has not been imported into a task.
     */
    private func checkImportStatusForReminder(_ reminder: EKReminder) -> Bool {
        let hasFoundEquivalentTask = taskModel.tasks.contains { task -> Bool in
            
            // Checks if a task is a Reminders import
            guard let reminderInfo = task.importData?.remindersImportData else { return false }
            
            // Checks if the task is associated with the reminder
            let isEquivalentTask =
                reminderInfo.calendarItemExternalIdentifier == reminder.calendarItemExternalIdentifier ||
           		reminderInfo.calendarItemIdentifier == reminder.calendarItemIdentifier
            
            return isEquivalentTask
        }
        
        return hasFoundEquivalentTask
    }
    
    // Convert a reminder to a Task and a Tag
    private func convertTaskAndTag(from reminder: EKReminder) -> (Task, Tag) {
        let attributes: [TaskModel.Attributes : Any] =
            [.title : reminder.title]
        let task =
            self.taskModel.createTask(with: attributes)
        let tag =
            self.tagModel.createTag(with: reminder.calendar.title)
    
        task.isCompleted = reminder.isCompleted
        task.completionDate = reminder.completionDate
        task.dueDate = reminder.completionDate
        task.creationDate = reminder.creationDate
        
        task.addToTags(tag)
        
        taskModel.associateTask(task,
                                with: .remindersDataPacket(id: reminder.calendarItemIdentifier,
                                                           externalId: reminder.calendarItemIdentifier))
	
        return (task, tag)
    }
    
    public func saveTaskToReminders(_ task: Task) {
        remindersDB.save(task: task)
    }
}

extension RemindersImporter: RemindersCommunicatorDelegate {
    
    func remindersCommunicatorDidDetectEventStoreChange(_ remindersCommunicator: RemindersCommunicator,
                                                        notification: NSNotification) {
        // TODO Figure out how to fetch the affected reminders without duplicating the whole Reminders Store
        // So far, seems like it is impossible.
    }
    
    func remindersCommunicatorWasGrantedAccessToReminders(_ remindersCommunicator: RemindersCommunicator) {
        // TODO Set persistent flag to avoid importing each time the app launches.
        importTasksFromReminders()
    }
    
    func remindersCommunicatorWasDeniedAccessToReminders(_ remindersCommunicator: RemindersCommunicator, error: Error) {
        // TODO Handle access denial
    }
}
