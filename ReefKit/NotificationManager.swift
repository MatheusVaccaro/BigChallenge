//
//  NotificationManager.swift
//  BigChallenge
//
//  Created by Gabriel Paul on 30/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UserNotifications
import CoreLocation /* remove this after rebase */

open class NotificationManager {
    
    /** Add a date notification from a task */
    open class func addDateNotification(for task: Task, repeats: Bool = false) {
        if let date = task.dueDate {
            let identifier = "\(task.id!)-date"
            let title = task.title!
            addDateNotification(identifier, title, repeats, date)
        }
    }
    
    /** Add a geofenced notification from a task */
    open class func addLocationNotification(for task: Task, repeats: Bool = false) {
        guard let regionData = task.regionData else { return }
        
        if let region = NSKeyedUnarchiver.unarchiveObject(with: regionData) as? CLCircularRegion {
            let identifier = "\(task.id!)-location"
            let title = task.title!
            addLocationNotification(identifier, title, task.isArriving, region)
        }
    }
    
    /** Remove location notification from a task */
    open class func removeLocationNotification(for task: Task) {
        let identifier = "\(task.id!)-location"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /** Remove date notification from a task */
    open class func removeDateNotification(for task: Task) {
        let identifier = "\(task.id!)-date"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /** Update all notifications from a task */
    open class func updateTaskNotifications(for task: Task) {
        removeDateNotification(for: task)
        removeLocationNotification(for: task)
        addDateNotification(for: task)
        addLocationNotification(for: task)
    }
    
    /** Add date and location notification for all tasks of a tag */
    open class func addAllTagNotifications(from tag: Tag, repeats: Bool = false) {
        guard let tasks = tag.tasks else { return }
        if let date = tag.dueDate {
            for case let task as Task in tasks where !task.isCompleted {
                let identifier = "\(task.id!)-\(tag.id!)-date"
                let title = task.title!
                addDateNotification(identifier, title, repeats, date)
            }
        }
        if let regionData = tag.regionData {
            if let region = NSKeyedUnarchiver.unarchiveObject(with: regionData) as? CLCircularRegion {
                for case let task as Task in tasks where !task.isCompleted {
                    let identifier = "\(task.id!)-\(tag.id!)-date"
                    let title = task.title!
                    let arriving = tag.arriving
                    addLocationNotification(identifier, title, arriving, region)
                }
            }
        }
    }
    
    /** Add date and location notification for all tasks of a tag */
    open class func addAllTagsNotifications(from tags: [Tag], repeats: Bool = false) {
        for tag in tags {
            addAllTagNotifications(from: tag)
        }
    }
    
    /** remove all date notifications from all associated tasks of a tag,
    does not remove tasks own notifications */
    open class func removeAllDateNotifications(from tag: Tag) {
        guard let tasks = tag.tasks else { return }
        
        var identifiersArray: [String] = []
        
        for case let task as Task in tasks {
            let identifier = "\(task.id!)-\(tag.id!)-date"
            identifiersArray.append(identifier)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersArray)
    }
    
    /** remove all location notifications from all associated tasks of a tag,
    does not remove tasks own notifications */
    open class func removeAllLocationNotifications(from tag: Tag) {
        guard let tasks = tag.tasks else { return }
        
        var identifiersArray: [String] = []
        
        for case let task as Task in tasks {
            let identifier = "\(task.id!)-\(tag.id!)-location"
            identifiersArray.append(identifier)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersArray)
    }
    
    /** remove all notifications from all associated tasks of a tag,
    does not remove tasks own notifications */
    open class func removeAllNotifications(from tag: Tag) {
        removeAllDateNotifications(from: tag)
        removeAllLocationNotifications(from: tag)
    }
    
    /** remove date notification from a specific task of a tag,
     does not remove task own notification */
    open class func removeSpecificDateNotification(from tag: Tag, task: Task) {
        let identifier = "\(task.id!)-\(tag.id!)-date"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /** remove location notification from a specific task of a tag,
     does not remove task own notification */
    open class func removeSpecificLocationNotification(from tag: Tag, task: Task) {
        let identifier = "\(task.id!)-\(tag.id!)-location"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /** Update all notifications from a tag */
    open class func updateTagNotifications(for tag: Tag) {
        removeAllNotifications(from: tag)
        addAllTagNotifications(from: tag)
    }
    
    /** Update all notifications from a tag */
    open class func updateTagsNotifications(for tags: [Tag]) {
        for tag in tags {
            updateTagNotifications(for: tag)
        }
    }
    
    /** Update all notifications from a tag */
    open class func removeAllTagsNotifications(for task: Task) {
        for tag in task.allTags {
            removeSpecificDateNotification(from: tag, task: task)
            removeSpecificLocationNotification(from: tag, task: task)
        }
    }
    
    fileprivate class func addLocationNotification(_ identifier: String,
                                                   _ title: String,
                                                   _ arriving: Bool,
                                                   _ region: CLRegion,
                                                   _ repeats: Bool = false,
                                                   _ subtitle: String? = nil) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.badge = 1
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.categoryIdentifier = "taskNotification"
        
        region.notifyOnEntry = arriving
        region.notifyOnExit = !arriving
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    fileprivate class func addDateNotification(_ identifier: String,
                                               _ title: String,
                                               _ repeats: Bool,
                                               _ date: Date,
                                               _ subtitle: String? = nil) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.badge = 1
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.categoryIdentifier = "taskNotification"
        
        let dateComponents = Calendar.current.dateComponents([
            .year,
            .month,
            .day,
            .hour,
            .minute],
                                                             from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { _ in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                for request in requests {
                    print(request.identifier)
                    print(request.trigger!)
                }
            }
        })
    }
}
