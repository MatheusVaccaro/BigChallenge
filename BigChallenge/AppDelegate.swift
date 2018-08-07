//
//  AppDelegate.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 23/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var applicationCoordinator: ApplicationCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        requestAuthorizationForNotifications()
        
        if let options = launchOptions {
            guard options[UIApplicationLaunchOptionsKey.userActivityDictionary] == nil else { return true }
        }
        
        // MARK: Application Coordinator
        startApplicationCoordinator(with: window, selectedTagIDs: [])
        
        return true
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let tagIDs = userActivity.userInfo!["selectedTagIDs"] as? [String]
        startApplicationCoordinator(with: window!, selectedTagIDs: tagIDs ?? [])
        return true
    }
    
    // MARK: - Helper Methods
    func startApplicationCoordinator(with window: UIWindow, selectedTagIDs: [String]) {
        let applicationCoordinator = ApplicationCoordinator(window: window, selectedTagIDs: selectedTagIDs)
        self.applicationCoordinator = applicationCoordinator
        applicationCoordinator.start()
    }
    
    func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in })
    }
    
}
