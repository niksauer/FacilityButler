//
//  FloorPlan.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 28.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class FloorPlan: NSObject, NSCoding {
    
    // MARK: - Instance Properties
    let etage: Int
    var blueprint: [Line]?
    
    // MARK: - Types
    enum OrdinalNumber: String {
        case ground
        case first = "st"
        case second = "nd"
        case third = "rd"
        case fourth = "th"
    }

    // MARK: - Initialization
    init(etage: Int) {
        self.etage = etage
        self.blueprint = [Line]()
    }
    
    // MARK: - NSCoding Protocol
    required init?(coder aDecoder: NSCoder) {
        if let blueprint = aDecoder.decodeObject(forKey: PropertyKey.blueprint) as? [Line] {
            let etage = aDecoder.decodeInteger(forKey: PropertyKey.etage)
            self.etage = etage
            self.blueprint = blueprint
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(etage, forKey: PropertyKey.etage)
        aCoder.encode(blueprint, forKey: PropertyKey.blueprint)
    }
    
    // MARK: - Class Functions
    // INFO: returns etage as ordinal string, i.e.: 3 -> "3rd upper floor"
    static func getOrdinal(ofFloor number: Int, capitalized: Bool) -> String {
        let ordinalNumber: OrdinalNumber
        let result: String
        
        switch number {
        case 0:
            ordinalNumber = .ground
        case -1, 1:
            ordinalNumber = .first
        case -2, 2:
            ordinalNumber = .second
        case -3, 3:
            ordinalNumber = .third
        default:
            ordinalNumber = .fourth
        }
        
        if ordinalNumber != .ground {
            let floorType = number > 0 ? "upper" : "lower"
            let floorNumber = "\(abs(number))\(ordinalNumber.rawValue)"
            let floorName = "\(floorType) floor"
            result = capitalized ? "\(floorNumber) \(floorName.capitalized)" : "\(floorNumber) \(floorName)"
            return result
        } else {
            result = "\(ordinalNumber) floor"
            return capitalized ? result.capitalized : result
        }
    }

}
