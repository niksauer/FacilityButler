//
//  Facility.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class Facility: NSObject, NSCoding {
    
    // MARK: - Instance Properties
    var floors: [FloorPlan]
    var currentFloor: Int
    var placedAccessoires: [PlacedAccessory]
    
    // MARK: - Initialization
    override init() {
        let groundFloor = FloorPlan(etage: 0)
        self.floors = [groundFloor]
        self.currentFloor = 0
        self.placedAccessoires = [PlacedAccessory]()
        super.init()
        log.debug("Created new facility \(self)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let floors = aDecoder.decodeObject(forKey: PropertyKey.floors) as? [FloorPlan], let placed = aDecoder.decodeObject(forKey: PropertyKey.placedAccessories) as? [PlacedAccessory] {
            let currentFloor = aDecoder.decodeInteger(forKey: PropertyKey.currentFloor)
            
            self.floors = floors
            self.currentFloor = currentFloor
            self.placedAccessoires = placed
            super.init()
            
            log.info("Loaded previously saved facility \(self)")
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

    // INFO: places accessory on current floor
    func placeAccessory(_ accessory: HMAccessory) throws {
        if floors.index(where: { $0.etage == currentFloor }) != nil {
            if placedAccessoires.contains(where: { $0.uniqueIdentifier == accessory.uniqueIdentifier.uuidString }) == false {
                placedAccessoires.append(PlacedAccessory(uniqueIdentifier: accessory.uniqueIdentifier.uuidString, floorNumber: currentFloor))
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
    
    func getPlacedAccessoires() -> [String] {
        var accessoires = [String]()
        
        for accessory in placedAccessoires {
            accessoires.append(accessory.uniqueIdentifier)
        }
        
        return accessoires
    }
    
    func getPlacedAccessoriesOfFloor(_ number: Int) -> [String] {
        var accessories = [String]()
        
        for accessory in placedAccessoires {
            if accessory.floorNumber == number {
                accessories.append(accessory.uniqueIdentifier)
            }
        }
        
        return accessories
    }
    
    // MARK: - NSCoding Protocol & Archiving
    func encode(with aCoder: NSCoder) {
        aCoder.encode(floors, forKey: PropertyKey.floors)
        aCoder.encode(currentFloor, forKey: PropertyKey.currentFloor)
        aCoder.encode(placedAccessoires, forKey: PropertyKey.placedAccessories)
    }
    
    static func loadFacility(identifier: String) -> Facility? {
        let archiveURL = DocumentsDirectory.appendingPathComponent("facility_\(identifier)")
        return NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? Facility
    }
    
    func save() throws {
        let archiveURL = DocumentsDirectory.appendingPathComponent("facility_\(instance.uniqueIdentifier)")
        
        if NSKeyedArchiver.archiveRootObject(self as Any, toFile: archiveURL.path) {
            log.info("Saved current state")
        } else {
            log.error("Failed to save current state")
            throw FacilityError.actionFailed(error: "Failed to save current state" as! Error)
        }
    }
    
}
