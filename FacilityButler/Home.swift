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
    case noAccessory
    case failed(error: Error)
}

class Home {
    // MARK: - Properties
    var currentHome: HMHome?
    let manager = HMHomeManager()
    
    // MARK: - Actions
    func setCurrentHome(_ home: HMHome?, completion: () -> Void) {
        if !manager.homes.isEmpty && currentHome != manager.primaryHome {
            currentHome = manager.primaryHome
            os_log("Set current home: %@ with accessoires: %@", log: OSLog.default, type: .debug, currentHome!, currentHome!.accessories)
            completion()
        }
    }
    
    // TODO: - Show result messages as popup
    func saveAccessory(accessory: HMAccessory?, completion: @escaping (Error?) -> Void) {
        guard let home = currentHome else {
            os_log("No home set", log: OSLog.default, type: .debug)
            completion(HomeError.noHomeSet)
            return
        }
        
        if let accessory = accessory {
            if home.accessories.contains(accessory) == false {
                os_log("Attempting to add accessory to home: %@", log: OSLog.default, type: .debug, accessory as CVarArg)
                
                home.addAccessory(accessory, completionHandler: { (errorMessage) in
                    if let error = errorMessage {
                        os_log("Failed to add accessory to home: %@", log: OSLog.default, type: .debug, error as CVarArg)
                        completion(HomeError.failed(error: error))
                    } else {
                        os_log("Added accessory to home", log: OSLog.default, type: .debug)
                        completion(nil)
                    }
                })
            } else {
                completion(nil)
            }
        } else {
            os_log("No accessory selected", log: OSLog.default, type: .debug)
            completion(HomeError.noAccessory)
        }
    }
    
    // TODO: - Show result messages as popup
    func deleteAccessory(accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        guard let home = currentHome else {
            os_log("No home set", log: OSLog.default, type: .debug)
            completion(HomeError.noHomeSet)
            return
        }
        
        if home.accessories.contains(accessory) == true {
            home.removeAccessory(accessory, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    os_log("Failed to remove accessory from home: %@", log: OSLog.default, type: .debug, error as CVarArg)
                    completion(HomeError.failed(error: error))
                } else {
                    os_log("Removed accessory from home", log: OSLog.default, type: .debug)
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
