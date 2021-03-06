//
//  AppDelegate.swift
//  Landlord
//
//  Created by Przemyslaw Blasiak on 01.11.2014.
//  Copyright (c) 2014 bprzemyslaw. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.statusBarStyle = .LightContent
        
        // Setup Parse
        Parse.setApplicationId("C4rbjhuWyKxoV8qyyT3Xt1KD1fq9E9BuWtQz3Fsa", clientKey: "vKVZVLijNzVqcBFPgCjbLSLpmUiS5opIYh0ntiTQ")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        // Setup PTBKit
        var darkBlue = UIColor(red: 26/255, green: 34/255, blue: 47/255, alpha: 1)
        var goldYellow = UIColor(red: 255/255, green: 181/255, blue: 6/255, alpha: 1)
        PTBSettings.sharedInstance.setColorPalette(interactiveColor: goldYellow, informativeColor: UIColor.whiteColor(), backgroundColor: darkBlue)
        
        return true;
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

    // Called when the application is about to terminate.
    func applicationWillTerminate(application: UIApplication) {
    }

}

