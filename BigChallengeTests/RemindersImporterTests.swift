//
//  RemindersImporterTests.swift
//  BigChallengeTests
//
//  Created by Max Zorzetti on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Quick
import Nimble
import os

@testable
import BigChallenge

/*
 Affected user stories:
    - Import Tasks from other Services
*/

class RemindersImporterTests: QuickSpec {
    
    override func spec() {
        describe("the RemindersImporter") {
            
            var remindersImporter: RemindersImporter!
            var communicator: MockRemindersCommunicator!
            var taskModel: TaskModel!
            var reminder: Reminder!
            var task: Task!
            
            beforeEach {
                let mockPersistence = Persistence(configuration: .inMemory)
                let tagModel = TagModel(persistence: mockPersistence)
                taskModel = TaskModel(persistence: mockPersistence)
                communicator = MockRemindersCommunicator()
                remindersImporter = RemindersImporter(taskModel: taskModel, tagModel: tagModel, communicator: communicator)
            }
            
            context("when importing tasks") {
                
                beforeEach {
                    remindersImporter.attemptToImport()
                }
                
                it("should import all tasks from Reminders") {
                    let taskModelReminderDataPackets: [MockDataPacket] = taskModel.tasks.compactMap {
                        guard let remindersData = $0.importData?.remindersImportData else { return nil }
                        
                        let idPacket = MockDataPacket(id: remindersData.calendarItemIdentifier!,
                                                  externalID: remindersData.calendarItemExternalIdentifier)
                        
                        return idPacket
                    }
                    
                    let remindersDataPackets: [MockDataPacket] = communicator.reminders.map {
                        let idPacket = MockDataPacket(id: $0.calendarItemIdentifier,
                                                      externalID: $0.calendarItemExternalIdentifier)
                        
                        return idPacket
                    }
                    
                    expect(taskModelReminderDataPackets).to(contain(remindersDataPackets))
                }
            }
            
            context("when exporting a task") {
                
                beforeEach {
                    task = taskModel.createTask(with: [.title: "Title"])
                    taskModel.save(task)
                    reminder = remindersImporter.exportTaskToReminders(task)
                }
                
                it("should associate reminder data to it") {
                    guard let reminderData = task.importData?.remindersImportData,
                    case .remindersDataPacket(let taskId, let taskExternalId) = ImportDataPacket.from(reminderData),
                    case .remindersDataPacket(let reminderId, let reminderExternalId) = reminder.dataPacket else {
                        return
                    }
                    
                    expect(taskId).to(equal(reminderId))
                    expect(taskExternalId).to(equal(reminderExternalId))
                }
                
                it("should export it to Reminders") {
                    let exportedReminder = communicator.fetchReminder(identifiedBy: reminder.dataPacket)
                    
                    expect(exportedReminder).notTo(beNil())
                }
            }
            
            context("when syncing in realtime") {
                it("should import new tasks from Reminders automatically") {
                    let newReminder = communicator.createReminder()
                    communicator.save(newReminder)
                    
                    expect(taskModel.tasks).to(containElementSatisfying({ task -> Bool in
                        guard let remindersData = task.importData?.remindersImportData else { return false }
                        
                        return remindersData.calendarItemIdentifier == newReminder.calendarItemIdentifier ||
                        	remindersData.calendarItemExternalIdentifier == newReminder.calendarItemExternalIdentifier
                    }))
                }
            }
        }
    }
}

// MARK: - Mocks

import EventKit

struct MockDataPacket: Hashable {
    let id: String
    let externalID: String?
}

class MockRemindersCommunicator: RemindersCommunicator {
    var reminders: [Reminder] = [] {
        didSet {
            delegate?.remindersCommunicatorDidDetectEventStoreChange(self, notification: NSNotification(name: NSNotification.Name("Mock"), object: nil))
        }
    }
    
    var calendars: [EKCalendar] = []
    var defaultCalendar: EKCalendar = EKEventStore().defaultCalendarForNewReminders()!
    
    override func requestAccess() {
        self.delegate?.remindersCommunicatorWasGrantedAccessToReminders(self)
    }
    
    override public func fetchAllReminders(completion: @escaping (([Reminder]?) -> Void)) {
		completion(Array(reminders))
    }
    
    override public func fetchIncompleteReminders(completion: @escaping ([Reminder]?) -> Void) {
        completion(reminders.filter({ !$0.isCompleted }))
    }
    
    override public func fetchReminder(withIdentifier identifier: String) -> Reminder? {
        return reminders.first(where: { $0.calendarItemIdentifier == identifier })
    }
    
    override public func fetchReminder(withExternalIdentifier identifier: String) -> Reminder? {
        return reminders.first(where: { $0.calendarItemExternalIdentifier == identifier })
    }
    
    override public func fetchReminder(identifiedBy dataPacket: ImportDataPacket) -> Reminder? {
        guard case .remindersDataPacket(let id, let externalId) = dataPacket else { return nil }
        
        return fetchReminder(withIdentifier: id) ?? fetchReminder(withExternalIdentifier: externalId ?? "")
    }
    
    @objc
    override func eventStoreChangedNotificationHandler(_ notification: NSNotification) {
        delegate?.remindersCommunicatorDidDetectEventStoreChange(self, notification: notification)
    }
    
    // MARK: Reminder creation
    
    override public func createReminder() -> Reminder {
        let reminder = MockReminder()
        
        return reminder
    }
    
    override public func getCalendars() -> [EKCalendar] {
        return calendars
    }
    
    override public func getDefaultCalendar() -> EKCalendar {
        return defaultCalendar
    }
    
    override public func save(_ reminder: Reminder) {
        let possibleIndex = reminders.firstIndex(where: {
            $0.calendarItemIdentifier == reminder.calendarItemIdentifier ||
            $0.calendarItemExternalIdentifier == reminder.calendarItemExternalIdentifier
        })
        
        if let index = possibleIndex {
            reminders.remove(at: index)
            reminders.insert(reminder, at: index)
        } else {
            reminders.append(reminder)
        }
    }
}

class MockCalendar: EKCalendar {
    override init() {
    }
}

class MockReminder: Reminder {
    var isCompleted: Bool
    var title: String!
    var completionDate: Date?
    var dueDateComponents: DateComponents?
    var calendar: EKCalendar!
    var creationDate: Date?
    var calendarItemIdentifier: String
    var calendarItemExternalIdentifier: String!
    var dataPacket: ImportDataPacket {
        return ImportDataPacket.remindersDataPacket(id: calendarItemIdentifier,
                                                    externalId: calendarItemExternalIdentifier)
    }
    
    init(withTitle title: String = "Mock") {
        self.title = title
        self.isCompleted = false
        self.completionDate = nil
        self.dueDateComponents = nil
        self.calendar = nil
        self.creationDate = Date()
        self.calendarItemIdentifier = UUID().uuidString
        self.calendarItemExternalIdentifier = UUID().uuidString
    }
}
