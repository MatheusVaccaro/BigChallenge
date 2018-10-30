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
    private var hasAddedEventStoreObserver: Bool
    
    weak var delegate: RemindersCommunicatorDelegate?
    
    init(delegate: RemindersCommunicatorDelegate? = nil) {
        self.delegate = delegate
        self.store = EKEventStore()
        self.hasAddedEventStoreObserver = false
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
                
                if !self.hasAddedEventStoreObserver {
                    self.hasAddedEventStoreObserver = true
                    
                    let eventHandler = #selector(self.eventStoreChangedNotificationHandler(_:))
                    NotificationCenter.default.addObserver(self,
                                                           selector: eventHandler,
                                                           name: .EKEventStoreChanged, object: self.store)
                }
            } else {
                self.delegate?.remindersCommunicatorWasDeniedAccessToReminders(self)
            }
        }
    }
    
    public func fetchAllReminders(completion: @escaping (([Reminder]?) -> Void)) {
        let predicate = store.predicateForReminders(in: nil)
        
        store.fetchReminders(matching: predicate) { reminders in
            completion(reminders)
        }
    }
    
    public func fetchIncompleteReminders(completion: @escaping ([Reminder]?) -> Void) {
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        
        store.fetchReminders(matching: predicate, completion: completion)
    }
    
    public func fetchReminder(withIdentifier identifier: String) -> Reminder? {
    	return store.calendarItem(withIdentifier: identifier) as? EKReminder
    }
    
    public func fetchReminder(withExternalIdentifier identifier: String) -> Reminder? {
        return store.calendarItems(withExternalIdentifier: identifier).first as? EKReminder
    }
    
    public func fetchReminder(identifiedBy dataPacket: ImportDataPacket) -> Reminder? {
        guard case .remindersDataPacket(let id, let externalId) = dataPacket else { return nil }
        
        return fetchReminder(withIdentifier: id) ?? fetchReminder(withExternalIdentifier: externalId ?? "")
    }
    
    // Warns delegate about a change in the Reminders app
    @objc
    func eventStoreChangedNotificationHandler(_ notification: NSNotification) {
        delegate?.remindersCommunicatorDidDetectEventStoreChange(self, notification: notification)
    }
    
    // MARK: Reminder creation
    
    public func createReminder() -> Reminder {
        let reminder = EKReminder(eventStore: store)
        
        return reminder
    }
    
    public func getCalendars() -> [EKCalendar] {
        return store.calendars(for: .reminder)
    }
    
    public func getDefaultCalendar() -> EKCalendar? {
        return store.defaultCalendarForNewReminders()
    }
    
    public func save(_ reminder: Reminder) {
        guard let ekReminder = reminder as? EKReminder else { return }
        
        do {
            try store.save(ekReminder, commit: true)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}

protocol RemindersCommunicatorDelegate: class {
    func remindersCommunicatorWasGrantedAccessToReminders(_ remindersCommunicator: RemindersCommunicator)
    func remindersCommunicatorWasDeniedAccessToReminders(_ remindersCommunicator: RemindersCommunicator)
    func remindersCommunicatorDidDetectEventStoreChange(_ remindersCommunicator: RemindersCommunicator,
                                                        notification: NSNotification)
}

extension EKReminder: Reminder {

    public var dataPacket: ImportDataPacket {
        return ImportDataPacket.remindersDataPacket(id: calendarItemIdentifier,
                                                    externalId: calendarItemExternalIdentifier)
    }
}
