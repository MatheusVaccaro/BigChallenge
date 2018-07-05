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
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil,
                                                              ending: nil,
                                                              calendars: nil)
        
        store.fetchReminders(matching: predicate) { reminders in
            completion(reminders!)
        }
    }
    
}
