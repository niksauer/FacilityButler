//
//  PlacedAccessory.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 03.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation

class PlacedAccessory: NSObject, NSCoding {
    
    // MARK: - Instance Properties
    let uniqueIdentifier: String
    var floorNumber: Int
    
    // MARK: - Initialization
    init(uniqueIdentifier: String, floorNumber: Int) {
        self.uniqueIdentifier = uniqueIdentifier
        self.floorNumber = floorNumber
    }
    
    // MARK: - NSCoding Protocol
    required convenience init?(coder aDecoder: NSCoder) {
        if let identifier = aDecoder.decodeObject(forKey: PropertyKey.uniqueIdentifier) as? String {
            let floorNumber = aDecoder.decodeInteger(forKey: PropertyKey.floorNumber)
            self.init(uniqueIdentifier: identifier, floorNumber: floorNumber)
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqueIdentifier, forKey: PropertyKey.uniqueIdentifier)
        aCoder.encode(floorNumber, forKey: PropertyKey.floorNumber)
    }
    
}
