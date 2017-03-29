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
        let groundFloor = FloorPlan(etage: 0)
        floors.append(groundFloor)
    }
    
    // MARK: - Actions
    func setHome(completion: () -> Void) {
        if let home = manager.primaryHome, self.home == nil {
            self.home = home
            log.debug("set home \(self.home!) with accessories \(self.home!.accessories)")
            completion()
        }
    }
    
    func saveAccessory(accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        guard let home = home else {
            log.warning("no home set")
            completion(HomeError.noHomeSet)
            return
        }
    
        if home.accessories.contains(accessory) == false {
            home.addAccessory(accessory, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error("failed to add accessory to home, due to: \(error)")
                    completion(HomeError.failed(error: error))
                } else {
                    log.info("added accessory \(accessory) to home")
                    completion(nil)
                }
            })
        } else {
            log.debug("accessory \(accessory) already added to home")
            completion(nil)
        }
    }
    
    func deleteAccessory(accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        guard let home = home else {
            log.warning("no home set")
            completion(HomeError.noHomeSet)
            return
        }
        
        if home.accessories.contains(accessory) {
            home.removeAccessory(accessory, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error("failed to remove accessory \(accessory) from home")
                    completion(HomeError.failed(error: error))
                } else {
                    log.info("removed accessory \(accessory) from home")
                    completion(nil)
                }
            })
        } else {
            log.debug("accessory \(accessory) doesn't belong to home, cancelling removal")
        }
    }

    // INFO: - places accessory on current floor
    func placeAccessory(_ accessory: HMAccessory) throws {
        if let floorIndex = floors.index(where: { $0.etage == currentFloor }) {
            if floors[floorIndex].accessoires.contains(where: { $0.uniqueIdentifier == accessory.uniqueIdentifier }) == false {
                floors[floorIndex].accessoires.append(accessory)
            } else {
                throw HomeError.alreadyPlaced
            }
        } else {
            throw HomeError.floorNotFound
        }
    }
    
    func createFloor(number: Int) {
        if floors.contains(where: { $0.etage == number }) == false {
            floors.append(FloorPlan(etage: number))
            log.info("created floor #\(number)")
        } else {
            log.debug("floor #\(number) already exists, cancelling creation")
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
