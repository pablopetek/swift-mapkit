//
//  AppDelegate.swift
//  swift-mapkit
//
//  Created by Dane Arpino on 3/11/15.
//  Copyright (c) 2015 DA. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        // Identifying users
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.objectForKey("ApplicationUniqueIdentifier") == nil {
            let UUID = NSUUID().UUIDString
            userDefaults.setObject(UUID, forKey: "ApplicationUniqueIdentifier")
            userDefaults.synchronize()
        }
        
        // Parse
        // Initialize Parse.
        Parse.setApplicationId("Cs5lDo8YXcVenvFKnoiNZO46L584P6dQzvUCsiOw", clientKey: "NjWXuNY59QklaR6Xz5S6P7VlzQjhhXBI5bOwgsCi")
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    
    // ---
    
    
}

