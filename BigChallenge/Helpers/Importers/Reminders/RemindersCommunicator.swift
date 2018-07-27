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
    
    private let store: EKEventStore
    
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
    
    public func fetchAllReminders(completion: @escaping (([EKReminder]?) -> Void)) {
        let predicate = store.predicateForReminders(in: nil)
        
        store.fetchReminders(matching: predicate) { reminders in
            completion(reminders)
        }
    }
    
    // Warns delegate about a change in the Reminders app
    @objc
    func eventStoreChangedNotificationHandler(_ notification: NSNotification) {
        delegate?.remindersCommunicatorDidDetectEventStoreChange(self, notification: notification)
    }
    
    // MARK: Reminder creation
    
    public func createReminder() -> EKReminder {
        let reminder = EKReminder(eventStore: store)
        
        return reminder
    }
    
    public func getCalendars() -> [EKCalendar] {
        return store.calendars(for: .reminder)
    }
    
    public func getDefaultCalendar() -> EKCalendar {
        guard let defaultCalendar = store.defaultCalendarForNewReminders() else {
            fatalError("No default calendar for new reminders has been set.")
        }
        
        return defaultCalendar
    }
    
    public func save(_ reminder: EKReminder) {
        do {
            try store.save(reminder, commit: true)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}

protocol RemindersCommunicatorDelegate: class {
    func remindersCommunicatorWasGrantedAccessToReminders(_ remindersCommunicator: RemindersCommunicator)
    func remindersCommunicatorWasDeniedAccessToReminders(_ remindersCommunicator: RemindersCommunicator, error: Error)
    func remindersCommunicatorDidDetectEventStoreChange(_ remindersCommunicator: RemindersCommunicator,
                                                        notification: NSNotification)
}

extension EKReminder {
    var dataPacket: ImportDataPacket {
        return ImportDataPacket.remindersDataPacket(id: calendarItemIdentifier,
                                                    externalId: calendarItemExternalIdentifier)
    }
}
