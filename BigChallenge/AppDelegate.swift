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
        
        // MARK: Application Coordinator
        startApplicationCoordinator(with: window)
        
        requestAuthorizationForNotifications()
        
        return true
    }
    
    private func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        // MARK: Application Coordinator
        let tags = userActivity.userInfo!["selectedTags"] as? [Tag]
        startApplicationCoordinator(with: window, selectedTags: tags ?? [])
        
        return true
    }
    
    // MARK: - Helper Methods
    func startApplicationCoordinator(with window: UIWindow, selectedTags: [Tag] = []) {
        let applicationCoordinator = ApplicationCoordinator(window: window,
                                                            selectedTags: selectedTags)
        self.applicationCoordinator = applicationCoordinator
        applicationCoordinator.start()
    }
    
    func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in })
    }
    
}
