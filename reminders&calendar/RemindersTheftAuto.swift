//
//  RemindersTheftAuto.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 04/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import EventKit

public class CommReminders {
    
    var store: EKEventStore = EKEventStore()
    
    init() {
        store.requestAccess(to: .reminder) { granted, error in
            if granted {
                self.store = EKEventStore()
            } else {
                print("user didnt grant reminders access")
            }
        }
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
        
        //TODO save only if is new reminder
        let predicate = store.predicateForReminders(in: [calendar!])
        
        store.fetchReminders(matching: predicate) {
            
            let matchingReminders = $0!.filter { $0.title == reminder.title }
            
            print(matchingReminders.map { $0.title })
            
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
