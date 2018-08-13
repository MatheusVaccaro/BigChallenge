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
            let identifier = "\(task.title!)-date"
            let title = task.title ?? Strings.Notification.placeholderTitle
            addDateNotification(identifier, title, repeats, date)
        }
    }
    
    /** Add a geofenced notification from a task */
    open class func addLocationNotification(for task: Task, repeats: Bool = false) {
        guard let regionData = task.regionData else { return }
        
        if let region = NSKeyedUnarchiver.unarchiveObject(with: regionData) as? CLCircularRegion {
            let identifier = "\(task.title!)-location"
            let title = task.title ?? Strings.Notification.placeholderTitle
            addLocationNotification(identifier, title, task.arriving, region)
        }
    }
    
    /** Remove location notification from a task */
    open class func removeLocationNotification(for task: Task) {
        let identifier = "\(task.title!)-location"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /** Remove date notification from a task */
    open class func removeDateNotification(for task: Task) {
        let identifier = "\(task.title!)-date"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /** Add date and location notification for all tasks of a tag */
    open class func addAllTagNotifications(from tag: Tag, repeats: Bool = false, arriving: Bool = false) {
        guard let tasks = tag.tasks else { return }
        if let date = tag.dueDate {
            for case let task as Task in tasks {
                let identifier = "\(task.title!)-\(tag.title!)-date"
                let title = task.title!
                addDateNotification(identifier, title, repeats, date)
            }
        }
        //TODO: Location
    }
    
    /** remove all date notifications from all associated tasks of a tag,
    does not remove tasks own notifications */
    open class func removeAllDateNotifications(from tag: Tag) {
        guard let tasks = tag.tasks else { return }
        guard tag.dueDate != nil else { return }
        
        var identifiersArray: [String] = []
        
        for case let task as Task in tasks {
            let identifier = "\(task.title!)-\(tag.title!)-date"
            identifiersArray.append(identifier)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersArray)
    }
    
    /** remove all location notifications from all associated tasks of a tag,
    does not remove tasks own notifications */
    open class func removeAllLocationNotifications(from tag: Tag) {
        guard let tasks = tag.tasks else { return }
//        guard tag.location != nil else { return }
        
        var identifiersArray: [String] = []
        
        for case let task as Task in tasks {
            let identifier = "\(task.title!)-\(tag.title!)-location"
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
        guard tag.dueDate != nil else { return }
        let identifier = "\(task.title!)-\(tag.title!)-date"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /** remove location notification from a specific task of a tag,
     does not remove task own notification */
    open class func removeSpecificLocationNotification(from tag: Tag, task: Task) {
//        guard tag.region != nil else { return }
        let identifier = "\(task.title!)-\(tag.title!)-location"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    fileprivate class func addLocationNotification(_ identifier: String,
                                                   _ title: String,
                                                   _ arriving: Bool,
                                                   _ region: CLRegion,
                                                   _ repeats: Bool = false) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.badge = 1
        
        region.notifyOnEntry = arriving
        region.notifyOnExit = !arriving
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    fileprivate class func addDateNotification(_ identifier: String,
                                               _ title: String,
                                               _ repeats: Bool,
                                               _ date: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.badge = 1
        
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
