//
//  RemindersImporter.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 04/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import EventKit
import ReefKit

public class RemindersImporter {
    
    public static var instance: RemindersImporter?
    
    weak var delegate: RemindersImporterDelegate?
    
	private let taskModel: TaskModel
    private let tagModel: TagModel
    private let remindersDB: RemindersCommunicator
    
    private(set) var isSyncing: Bool
    private(set) var isImporting: Bool
    
    private var lastImportedTags: Set<Tag>
    private var lastImportedTasks: Set<Task>
    
    static var isImportingDefined: Bool {
        return EKEventStore.authorizationStatus(for: .reminder) != EKAuthorizationStatus.notDetermined
    }

    init(taskModel: TaskModel, tagModel: TagModel, communicator: RemindersCommunicator = RemindersCommunicator()) {
        self.taskModel = taskModel
        self.tagModel = tagModel
		self.remindersDB = communicator
        self.lastImportedTasks = []
        self.lastImportedTags = []
        defer { remindersDB.delegate = self }
        self.isImporting = false
        self.isSyncing = false
    }
    
    /**
     Attempts to start the import procedure.
     If sucessful, will import all reminders that have not been imported yet.
 	*/
    func requestAndImport() {
        remindersDB.requestAccess()
    }
    
    /// import from remidners only if permission is already granted
    func importIfGranted() {
        guard EKEventStore.authorizationStatus(for: .reminder) == .authorized else { return }
        
        importTasksFromReminders()
    }

    /**
     This method fetches all incomplete reminders from the Reminders internal store,
     converts them to tasks and tags, and then finally saves them to our own store.
     */
    private func importTasksFromReminders() {
        guard !isImporting else { return }
        
        delegate?.remindersImportedDidStartImport(self)
        isImporting = true
        
        remindersDB.fetchAllReminders { allReminders in
            guard let reminders = allReminders else {
                self.isImporting = false
                
                return
            }
            
            // Convert reminders to task and tag data.
            var importedTagsInformation = [TagInformation]()
            var importedTasksInformation = [(TaskInformation, Reminder)]()
            
            // Parse all reminders that were not yet imported
            for reminder in reminders where !self.checkImportStatus(for: reminder) {
                
                let tagInformation = self.convertTagInformation(from: reminder)
                // Check for duplicate tags
                if let tagTitle = tagInformation[.title] as? String,
                   !importedTagsInformation.compactMap({ $0[.title] as? String }).contains(where: { $0 == tagTitle }) {
        
                    importedTagsInformation.append(tagInformation)
                }
                
                let taskInformation = self.convertTaskInformation(from: reminder)
                importedTasksInformation.append((taskInformation, reminder))
            }
            
            // Create tags and tasks and link them properly.

            let newTags = importedTagsInformation.map({ self.tagModel.createTag(with: $0) })
			
            let newTasks = importedTasksInformation.map({ importedTaskData -> Task in
                var (taskInformation, reminder) = importedTaskData
                let tagName = reminder.calendar.title
                
                // Retrieve the tag object created above, using its name
                let tag = newTags.first(where: { $0.title == tagName })!
                taskInformation[.tags] = [tag]
                
                // Create the task and mark it as an imported task
                let task = self.taskModel.createTask(with: taskInformation)
                self.taskModel.associate(task, with: reminder.dataPacket)
                
                return task
            })
            
            self.lastImportedTags = Set(newTags)
            self.lastImportedTasks = Set(newTasks)
            self.isImporting = false
            self.delegate?.remindersImporterDidFinishImport(self)
        }
    }
    
    func consumeNewImportedTags() -> Set<Tag> {
        let newImportedTags = self.lastImportedTags
        self.lastImportedTags.removeAll()
        
        return newImportedTags
    }
    
    func consumeNewImportedTasks() -> Set<Task> {
        let newImportedTasks = self.lastImportedTasks
        self.lastImportedTasks.removeAll()
        
        return newImportedTasks
    }
    
    /**
     Checks if a reminder has already been imported and converted into a task (i.e. has an equivalent task).
     
     - Parameter reminder: The reminder to check the import status of.
     
     - Returns: ```true``` if the reminder has been imported into a task.
     			```false``` if the reminder has not been imported into a task.
     */
    private func checkImportStatus(for reminder: Reminder) -> Bool {
        let hasFoundEquivalentTask = taskModel.tasks.contains { task -> Bool in
            
            // Checks if a task is a Reminders import
            guard let remindersData = task.importData?.remindersImportData else { return false }
            
            // Checks if the task is associated with the reminder
            let isEquivalentTask =
                remindersData.calendarItemExternalIdentifier == reminder.calendarItemExternalIdentifier ||
           		remindersData.calendarItemIdentifier == reminder.calendarItemIdentifier
            
            return isEquivalentTask
        }
        
        return hasFoundEquivalentTask
    }
    
    /**
     Searches for the task associated with a specific reminder.
     
     - Parameter reminder: The reminder to check the import status of.
     
     - Returns: a ```task``` if there is one associated with the ```reminder``` or
     ```nil``` if there isn't one.
     */
    private func getEquivalentTask(for reminder: Reminder) -> Task? {
        let equivalentTask = taskModel.tasks.first { task -> Bool in
            guard let remindersData = task.importData?.remindersImportData else { return false }
            
            return remindersData.calendarItemExternalIdentifier == reminder.calendarItemExternalIdentifier ||
                   remindersData.calendarItemIdentifier == reminder.calendarItemIdentifier
        }
        
        return equivalentTask
    }
    
    private func convertTaskInformation(from reminder: Reminder) -> TaskInformation {
        let taskInformation: TaskInformation =
            [.title : reminder.title as Any,
             .isCompleted : reminder.isCompleted,
             .completionDate : reminder.completionDate as Any,
             .dueDate : reminder.completionDate as Any,
             .creationDate : reminder.creationDate as Any]
        
        return taskInformation
    }
    
    private func convertTagInformation(from reminder: Reminder) -> TagInformation {
        let tagInformation: TagInformation =
            [.title : reminder.calendar.title as Any]
        
        return tagInformation
    }
    
    // Convert a reminder to a Task and a Tag
    private func convertTaskAndTag(from reminder: Reminder) -> (task: Task, tag: Tag) {
        let tagInformation: TagInformation =
            [.title : reminder.calendar.title as Any]
        let tag = tagModel.createTag(with: tagInformation)
        
        let taskInformation: TaskInformation =
            [.title : reminder.title as Any,
             .isCompleted : reminder.isCompleted,
             .completionDate : reminder.completionDate as Any,
             .dueDate : reminder.completionDate as Any,
             .creationDate : reminder.creationDate as Any,
             .tags : [tag] as Any]
        let task = taskModel.createTask(with: taskInformation)
        
        taskModel.associate(task, with: reminder.dataPacket)
	
        return (task, tag)
    }
    
    /**
     Exports a new task to Reminders or updates the existing reminder associated with one.
     
     - Parameter task: The task to export.
     */
    
    @discardableResult
    public func exportTaskToReminders(_ task: Task) -> Reminder? {
        guard !isImporting && !isSyncing else { return nil }
        
        // Attempts to retrieve an already existing reminder associated with the task
        let existingReminder: Reminder? = {
            if let remindersData = task.importData?.remindersImportData {
                let dataPacket = ImportDataPacket.from(remindersData)
                return remindersDB.fetchReminder(identifiedBy: dataPacket)
            } else { return nil }
        }()
        
        // Creates a new reminder if there isn't one associated with the task
        let reminder = existingReminder ?? remindersDB.createReminder()
    
        update(reminder, withDataFrom: task)
        taskModel.associate(task, with: reminder.dataPacket)
		
        remindersDB.save(reminder)
        
        return reminder
    }
    
    /**
     Updates a reminder with relevant data from a task.
     
     - Parameters
     	- reminder: The reminder to be updated.
        - task: The data source to update the reminder with.
     */
    private func update(_ reminder: Reminder, withDataFrom task: Task) {
        reminder.isCompleted = task.isCompleted
        reminder.title = task.title
        reminder.completionDate = task.completionDate
        
        if let dueDate = task.dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day,
                                                                          .hour, .minute], from: dueDate)
        }
        
        // TODO Implement a better way to figure out what list to save the reminder to.
        if let tag = task.tags?.anyObject() as? Tag,
           let calendar = remindersDB.getCalendars().first(where: { $0.title == tag.title }) {
            reminder.calendar = calendar
        } else {
            reminder.calendar = remindersDB.getDefaultCalendar()
        }
    }
    
    /**
     Calculates the differences between the Reminders store and ours.
     Updates our store based on said differences.
     Triggered when detecting a Reminders store change event.
     */
    private func syncWithReminders() {
        guard !isImporting && !isSyncing else { return }
        
        isSyncing = true
        
        // Check for changes between the model and the reminders store and update the model accordingly
        remindersDB.fetchAllReminders { allReminders in
            guard let reminders = allReminders else { return }
            
            // Set of all tasks originating from Reminders - even those not yet imported.
            let remindersSet = Set(reminders.map {
                self.getEquivalentTask(for: $0) ?? self.convertTaskAndTag(from: $0).task
            })
            let modelSet = Set(self.taskModel.tasks.filter({ $0.importData?.remindersImportData != nil }))
            
            let tasksToDelete = modelSet.subtracting(remindersSet)    // Reminders that were deleted in Reminders
            tasksToDelete.forEach({ self.taskModel.delete($0) })
            
            let newTasks = remindersSet.subtracting(modelSet)        // New reminders not yet imported.
            newTasks.forEach({ self.taskModel.save($0) })
            
            self.isSyncing = false
        }
    }
}

extension RemindersImporter: RemindersCommunicatorDelegate {
    func remindersCommunicatorDidDetectEventStoreChange(_ remindersCommunicator: RemindersCommunicator,
                                                        notification: NSNotification) {
        //syncWithReminders()
    }
    
    func remindersCommunicatorWasGrantedAccessToReminders(_ remindersCommunicator: RemindersCommunicator) {
        delegate?.remindersImporterWasGrantedPermission(self)
    }
    
    func remindersCommunicatorWasDeniedAccessToReminders(_ remindersCommunicator: RemindersCommunicator) {
        delegate?.remindersImporterWasDeniedPermission(self)
    }
}

protocol RemindersImporterDelegate: class {
    func remindersImportedDidStartImport(_ remindersImporter: RemindersImporter)
    func remindersImporterDidFinishImport(_ remindersImporter: RemindersImporter)
    func remindersImporterWasDeniedPermission(_ remindersImporter: RemindersImporter)
    func remindersImporterWasGrantedPermission(_ remindersImporter: RemindersImporter)
}

public protocol Reminder: class {
    var isCompleted: Bool { get set }
    var title: String! { get set }
    var completionDate: Date? { get set }
    var dueDateComponents: DateComponents? { get set }
    var calendar: EKCalendar! { get set }
    var creationDate: Date? { get }
    var calendarItemExternalIdentifier: String! { get }
    var calendarItemIdentifier: String { get }
    var dataPacket: ImportDataPacket { get }
}
