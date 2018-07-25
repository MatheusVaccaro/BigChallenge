//
//  RemindersTheftAuto.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 04/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import EventKit

public class RemindersCommunicator {
    
    let store: EKEventStore
    
    weak var delegate: RemindersCommunicatorDelegate?
    
    init(delegate: RemindersCommunicatorDelegate? = nil) {
        self.delegate = delegate
        self.store = EKEventStore()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Requests the user for access to the Reminders app
    // Warns delegate on access grant/denial
    func requestAccess() {
        store.requestAccess(to: .reminder) { granted, error in
            if granted {
                self.delegate?.remindersCommunicatorWasGrantedAccessToReminders(self)
                
                NotificationCenter.default.addObserver(self,
                                                    selector: #selector(self.eventStoreChangedNotificationHandler(_:)),
                                                    name: .EKEventStoreChanged, object: self.store)
                
            } else if let error = error {
                self.delegate?.remindersCommunicatorWasDeniedAccessToReminders(self, error: error)
            }
        }
    }
    
    // Warns delegate about a change in the Reminders app
    @objc
    func eventStoreChangedNotificationHandler(_ notification: NSNotification) {
        delegate?.remindersCommunicatorDidDetectEventStoreChange(self, notification: notification)
    }
    
    public func fetchAllReminders(completion: @escaping (([EKReminder]?) -> Void)) {
        let predicate = store.predicateForReminders(in: nil)
        
        store.fetchReminders(matching: predicate) { reminders in
            completion(reminders!)
        }
    }
    
    public func save(task: Task, commit: Bool = true) {
        let reminder = EKReminder(eventStore: store)
        var calendar = store.defaultCalendarForNewReminders()
        
        if let tagTitle = (task.tags?.anyObject() as? Tag)?.title {
            calendar = store.calendars(for: .reminder).first { $0.title == tagTitle }
        }
        
        reminder.title = task.title
        reminder.calendar = calendar
        
        //save only if is new reminder
        let predicate = store.predicateForReminders(in: [calendar!])
        
        store.fetchReminders(matching: predicate) {
            
            let matchingReminders = $0!.filter { $0.title == reminder.title }
            
            if matchingReminders.isEmpty {
                do {
                    try self.store.save(reminder, commit: true)
                } catch let error as NSError {
                    print("failed to save reminder with error \(error)")
                }
            }
        }
    }
}

protocol RemindersCommunicatorDelegate: class {
    func remindersCommunicatorWasGrantedAccessToReminders(_ remindersCommunicator: RemindersCommunicator)
    func remindersCommunicatorWasDeniedAccessToReminders(_ remindersCommunicator: RemindersCommunicator, error: Error)
    func remindersCommunicatorDidDetectEventStoreChange(_ remindersCommunicator: RemindersCommunicator,
                                                        notification: NSNotification)
}
