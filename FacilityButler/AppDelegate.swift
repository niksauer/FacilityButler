//
//  AppDelegate.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit
import SwiftyBeaver

let log = SwiftyBeaver.self
let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
let CachesDirectory = FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let model = FacilityButler()
    
    /// configures logging output, prints DocumentsDirectory and sets up initial view controller
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // logging config
        let console = ConsoleDestination()
    
        let file = FileDestination()
        let _ = file.deleteLogFile()
        file.format = "$DHH:mm:ss$d $N.$F - $L:\n$M \n"
        
        log.addDestination(console)
        log.addDestination(file)
        
        log.debug("Documents path: \(DocumentsDirectory)")
        log.debug("Caches path: \(CachesDirectory)")
        
        // Apply the selected theme from previous session
        ThemeManager.applyTheme(ThemeManager.currentTheme())
        
        // setup initial view controller
        let navigationController = window!.rootViewController as! UINavigationController
        let floorPlanController = navigationController.topViewController as! FloorPlanController
        floorPlanController.model = model
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        guard model.instance != nil else {
            return
        }
        
        log.debug("FacilityButler did enter background")
        
        do {
            try model.save()
        } catch {
            
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
//        log.debug("FacilityButler will enter foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
        guard model.instance != nil else {
            return
        }
        
        log.debug("FacilityButler did become active")
        
        let navigationController = window!.rootViewController as! UINavigationController
        
        if let floorPlanController = navigationController.topViewController as? FloorPlanController {
            floorPlanController.updateAccessories()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

