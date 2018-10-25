//
//  AppDelegate.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 23/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import CoreSpotlight
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var applicationCoordinator: ApplicationCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        if let options = launchOptions {
            guard options[UIApplication.LaunchOptionsKey.userActivityDictionary] == nil else { return true }
        }
        
        // MARK: Application Coordinator
        loadTheme()
        startApplicationCoordinator(with: window, selectedTagIDs: [])
        setNotificationCategories()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        applicationCoordinator?.refreshModel()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if uniqueIdentifier.starts(with: "task-") { //task
                    let taskID = String( uniqueIdentifier.dropFirst(5) )
                    startApplicationCoordinator(with: window!, selectedTask: taskID)
                    //start app with task
                } else if uniqueIdentifier.starts(with: "tag-") { // tag
                    let tagID = String( uniqueIdentifier.dropFirst(4) )
                    startApplicationCoordinator(with: window!, selectedTagIDs: [tagID])
                }
            }
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    func startApplicationCoordinator(with window: UIWindow, selectedTagIDs: [String]? = nil, selectedTask: String? = nil) {
        requestAuthorizationForNotifications()
        let applicationCoordinator = ApplicationCoordinator(window: window)
        self.applicationCoordinator = applicationCoordinator
        applicationCoordinator.start(selectedTagIDs: selectedTagIDs, taskID: selectedTask)
    }
    
    func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in })
    }
    
    private func loadTheme() {
        let theme = UserDefaults.standard.value(forKey: "ThemeMultiValue") as? Int ?? 0
        
        switch theme {
        case 1:
            UIColor.theme = Dark.self
        default:
            UIColor.theme = Classic.self
        }
        
        UITextField.appearance().keyboardAppearance = UIColor.theme.keyboardAppearance
    }
    
    private func setNotificationCategories() {
        
        //TODO: Localizate
        let completeAction = UNNotificationAction(identifier: "COMPLETE", title: Strings.Notification.complete, options: [])
        let postponeOneHour = UNNotificationAction(identifier: "POSTPONE_ONE_HOUR", title: Strings.Notification.postponeOneHour, options: [])
        let postponeOneDay = UNNotificationAction(identifier: "POSTPONE_ONE_DAY", title: Strings.Notification.postponeOneDay, options: [])
        
        let taskNotification =  UNNotificationCategory(identifier: "TASK_NOTIFICATION", actions: [completeAction, postponeOneHour, postponeOneDay], intentIdentifiers: [], options: .customDismissAction)
        
        
        UNUserNotificationCenter.current().setNotificationCategories([taskNotification])
    }
}
