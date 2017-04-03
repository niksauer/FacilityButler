//
//  FloorPlan.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 28.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

// MARK: - Global Types
struct Coordinate {
    var x: Int
    var y: Int
}

class FloorPlan: NSObject, NSCoding {
    // MARK: - Instance Properties
    let etage: Int
    
    // MARK: - Types
    enum OrdinalNumber: String {
        case ground
        case first = "st"
        case second = "nd"
        case third = "rd"
        case fourth = "th"
    }
    
    struct PropertyKey {
        static let etage = "etage"
    }
    
    // MARK: - Initialization
    init(etage: Int) {
        self.etage = etage
    }

    // MARK: - Class Functions
    // INFO: - returns etage as ordinal string, i.e.: 3 -> "3rd upper floor"
    static func getOrdinalFloorNumber(of number: Int, capitalized: Bool) -> String {
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
    
    // MARK: - NSCoding Protocol
    required convenience init?(coder aDecoder: NSCoder) {
        let etage = aDecoder.decodeInteger(forKey: PropertyKey.etage)
        self.init(etage: etage)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(etage, forKey: PropertyKey.etage)
    }
}
