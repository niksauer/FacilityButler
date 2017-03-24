//
//  FloorPlanModel.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class FloorPlanModel: NSObject, HMHomeManagerDelegate, HMAccessoryBrowserDelegate {
    var currentHome: HMHome?
    let homeManager = HMHomeManager()
    let accessoryBrowser = HMAccessoryBrowser()
    
    override init() {
        super.init()
        homeManager.delegate = self
    }
    
    // managing homes
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if !manager.homes.isEmpty {
            currentHome = manager.primaryHome
            print("current home: ", currentHome!)
        }
    }
    
    func createNewHome(name: String) {
        homeManager.addHome(withName: name, completionHandler: { (newHome, error) in
            print(error ?? "created new home")
        })
    }
    
    // managing accessoires
    func startAccessoryScan () {
        // start network scan of accessoires
        accessoryBrowser.startSearchingForNewAccessories()
        print("network scan started")
    }
    
    func stopAccessoryScan() {
        accessoryBrowser.stopSearchingForNewAccessories()
        print("network scan stopped")
    }
}
