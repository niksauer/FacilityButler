//
//  FloorPlanModel.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit
import os.log

enum HomeError: Error {
    case noHomeSet
    case failed(error: Error)
}

class Home {
    // MARK: - Properties
    var currentHome: HMHome?
    let manager = HMHomeManager()
    var placedAccessories = [HMAccessory]()
    
    // MARK: - Actions
    func setCurrentHome(_ home: HMHome?, completion: () -> Void) {
        if currentHome != home {
            currentHome = home
            os_log("Set current home: %@ with accessoires: %@", log: OSLog.default, type: .debug, currentHome!, currentHome!.accessories)
            completion()
        }
    }
    
    func saveAccessory(accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        guard let home = currentHome else {
            os_log("No home set", log: OSLog.default, type: .debug)
            completion(HomeError.noHomeSet)
            return
        }
        
        if home.accessories.contains(accessory) == false {
            home.addAccessory(accessory, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    os_log("Failed to add accessory to home: %@", log: OSLog.default, type: .debug, error as CVarArg)
                    completion(HomeError.failed(error: error))
                } else {
                    os_log("Added accessory to home", log: OSLog.default, type: .debug)
                    self.placedAccessories.append(accessory)
                    completion(nil)
                }
            })
        } else {
            placedAccessories.append(accessory)
            completion(nil)
        }
    }
    
    func deleteAccessory(accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        guard let home = currentHome else {
            os_log("No home set", log: OSLog.default, type: .debug)
            completion(HomeError.noHomeSet)
            return
        }
        
        if home.accessories.contains(accessory) {
            home.removeAccessory(accessory, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    os_log("Failed to remove accessory from home: %@", log: OSLog.default, type: .debug, error as CVarArg)
                    completion(HomeError.failed(error: error))
                } else {
                    os_log("Removed accessory from home", log: OSLog.default, type: .debug)
                    let index = self.placedAccessories.index(of: accessory)!
                    self.placedAccessories.remove(at: index)
                    completion(nil)
                }
            })
        }
    }

    // MARK: - Private Actions
//    private func createNewHome(name: String) {
//        manager.addHome(withName: name, completionHandler: { (newHome, errorMessage) in
//            if let error = errorMessage {
//                os_log("Failed to create home: %@", log: OSLog.default, type: .debug, error as CVarArg)
//            } else {
//                os_log("Created home: %@", log: OSLog.default, type: .debug, newHome!)
//            }
//        })
//    }
}
