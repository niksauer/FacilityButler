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
    var floors = [FloorPlan(etage: 0)]
    var currentFloor = 0
    var placedAccessoires = [PlacedAccessory]()
    
    // MARK: - Initialization
    override init() {
        log.debug("Created new facility")
    }
    
    // MARK: - NSCoding Protocol
    required init?(coder aDecoder: NSCoder) {
        if let floors = aDecoder.decodeObject(forKey: PropertyKey.floors) as? [FloorPlan], let placed = aDecoder.decodeObject(forKey: PropertyKey.placedAccessories) as? [PlacedAccessory] {
            let currentFloor = aDecoder.decodeInteger(forKey: PropertyKey.currentFloor)
            
            self.floors = floors
            self.currentFloor = currentFloor
            self.placedAccessoires = placed
        
            log.info("Loaded previously saved facility")
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(floors, forKey: PropertyKey.floors)
        aCoder.encode(currentFloor, forKey: PropertyKey.currentFloor)
        aCoder.encode(placedAccessoires, forKey: PropertyKey.placedAccessories)
    }
    
    // MARK: - Actions
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
    
    func unplaceAccessory(_ accessory: HMAccessory) throws {
        if floors.index(where: { $0.etage == currentFloor }) != nil {
            if placedAccessoires.contains(where: { $0.uniqueIdentifier == accessory.uniqueIdentifier.uuidString }) == true {
                let index = placedAccessoires.index(where: { $0.uniqueIdentifier == accessory.uniqueIdentifier.uuidString })!
                placedAccessoires.remove(at: index)
                log.info("removed placed accessory \(accessory) from floor #\(currentFloor)")
            } else {
                log.debug("accessory \(accessory) has not been placed on floor #\(currentFloor)")
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
    
    func getPlacedAccessories(ofFloor number: Int) -> [String] {
        var accessories = [String]()
        
        for accessory in placedAccessoires {
            if accessory.floorNumber == number {
                accessories.append(accessory.uniqueIdentifier)
            }
        }
        
        return accessories
    }
    
    func setBlueprint(_ lines: [Line]?) {
        if let floorIndex = floors.index(where: { $0.etage == currentFloor }) {
            floors[floorIndex].blueprint = lines
        }
    }
    
    func getBlueprint() -> [Line]? {
        if let floorIndex = floors.index(where: { $0.etage == currentFloor }) {
            return floors[floorIndex].blueprint
        } else {
            return nil
        }
    }
}
