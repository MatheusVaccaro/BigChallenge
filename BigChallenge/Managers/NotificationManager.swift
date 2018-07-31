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
    
    /** Add a notification */
    open class func addNotification(task: Task, repeats: Bool = false, arriving: Bool = false) {
        if let date = task.dueDate {
            let identifier = "\(task.title!)-date"
            
            let content = UNMutableNotificationContent()
            content.title = task.title ?? Strings.Notification.placeholderTitle
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
        //TODO: fix this when location screen is done
        if true /* let location = task.location */ {
            let identifier = "\(task.title!)-location"
            
            let content = UNMutableNotificationContent()
            content.title = task.title ?? Strings.Notification.placeholderTitle
            content.badge = 1
            
            let center = CLLocationCoordinate2D(latitude: -30.059401, longitude: -51.171411)
            let region = CLCircularRegion(center: center, radius: 1000, identifier: "TECNOPUC")
            region.notifyOnEntry = arriving
            region.notifyOnExit = !arriving
            let trigger = UNLocationNotificationTrigger(region: region, repeats: repeats)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}
