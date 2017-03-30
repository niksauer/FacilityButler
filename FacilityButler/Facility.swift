//
//  Facility.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

// MARK: - Global Types
enum FacilityError: Error {
    case floorNotFound
    case actionFailed(error: Error)
}

class Facility {
    // MARK: - Instance Properties
    let instance: HMHome
    var floors = [FloorPlan]()
    var currentFloor = 0
    var placedAccessoires = [PlacedAccessory]()
    
    // MARK: - Types
    struct PlacedAccessory {
        let uniqueIdentifier: UUID
        var floorNumber: Int
        var position: Coordinate
    }
    
    // MARK: - Initialization
    // INFO: - failes if no primary home is set, creates empty ground floor
    init?(manager: HMHomeManager) {
        if let home = manager.primaryHome {
            instance = home
            floors.append(FloorPlan(etage: 0))
        } else {
            return nil
        }
    }
    
    // MARK: - Actions
    func saveAccessory(_ accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        if instance.accessories.contains(accessory) == false {
            instance.addAccessory(accessory, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error("failed to add accessory to home, due to: \(error)")
                    completion(FacilityError.actionFailed(error: error))
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
    
    func deleteAccessory(_ accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        if instance.accessories.contains(accessory) {
            instance.removeAccessory(accessory, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error("failed to remove accessory \(accessory) from home")
                    completion(FacilityError.actionFailed(error: error))
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
        if floors.index(where: { $0.etage == currentFloor }) != nil {
            if placedAccessoires.contains(where: { $0.uniqueIdentifier == accessory.uniqueIdentifier }) == false {
                placedAccessoires.append(PlacedAccessory(uniqueIdentifier: accessory.uniqueIdentifier, floorNumber: currentFloor, position: Coordinate(x: 0, y: 0)))
                log.info("placed accessory \(accessory) on floor #\(currentFloor)")
            } else {
                log.debug("accessory \(accessory) already placed on floor #\(currentFloor)")
            }
        } else {
            log.warning("can't find floor #\(currentFloor), cancelling placement")
            throw FacilityError.floorNotFound
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
    
    func getPlacedAccessoires() -> [UUID] {
        var accessoires = [UUID]()
        
        for accessory in placedAccessoires {
            accessoires.append(accessory.uniqueIdentifier)
        }
        
        return accessoires
    }
    
    func getPlacedAccessoriesOfFloor(_ number: Int) -> [UUID] {
        var accessories = [UUID]()
        
        for accessory in placedAccessoires {
            if accessory.floorNumber == number {
                accessories.append(accessory.uniqueIdentifier)
            }
        }
        
        return accessories
    }
}
