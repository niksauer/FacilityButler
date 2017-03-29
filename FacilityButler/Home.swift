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
    case floorNotFound
    case alreadyPlaced
    case failed(error: Error)
}

class Home {
    // MARK: - Instance Properties
    let manager = HMHomeManager()
    var home: HMHome?
    var floors = [FloorPlan]()
    var currentFloor = 0
    
    // MARK: - Initialization
    // INFO: - Creates empty ground floor
    init() {
        let groundFloor = FloorPlan(etage: 0, name: "Ground Floor")
        floors.append(groundFloor)
    }
    
    // MARK: - Actions
    func setHome(completion: () -> Void) {
        if let home = manager.primaryHome, self.home == nil {
            self.home = home
            os_log("Set home: %@ with accessoires: %@", log: OSLog.default, type: .debug, self.home!, self.home!.accessories)
            completion()
        }
    }
    
    func saveAccessory(accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        guard let home = home else {
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
                    os_log("Added accessory to home: %@", log: OSLog.default, type: .debug, accessory as CVarArg)
                    completion(nil)
                }
            })
        } else {
            completion(nil)
        }
    }
    
    func deleteAccessory(accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        guard let home = home else {
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
                    os_log("Removed accessory from home: %@", log: OSLog.default, type: .debug, accessory as CVarArg)
                    completion(nil)
                }
            })
        }
    }

    // INFO: - places accessory on current floor
    func placeAccessory(_ accessory: HMAccessory) throws {
        if let floorIndex = floors.index(where: { $0.etage == currentFloor }) {
            if floors[floorIndex].accessoires.contains(where: { $0.uniqueIdentifier == accessory.uniqueIdentifier }) == false {
                floors[floorIndex].accessoires.append(accessory)
//                os_log("Placed accessory: %@ on current floor", log: OSLog.default, type: .debug, accessory as CVarArg)
            } else {
//                os_log("Accessory already placed on current floor", log: OSLog.default, type: .debug)
                throw HomeError.alreadyPlaced
            }
        } else {
//            os_log("Can't find floor, cancelling placement", log: OSLog.default, type: .debug, currentFloor as CVarArg)
            throw HomeError.floorNotFound
        }
    }
    
    func createFloor(number: Int) {
        if floors.contains(where: { $0.etage == number }) == false {
            floors.append(FloorPlan(etage: number))
        }
    }
    
    func getPlacedAccessoires() -> [HMAccessory] {
        var placed =  [HMAccessory]()
        
        for floor in floors {
            for accessory in floor.accessoires {
                placed.append(accessory)
            }
        }
        
        return placed
    }
}
