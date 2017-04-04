//
//  GlobalTypes.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 03.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation

// MARK: - Global Types
struct PropertyKey {
    static let instance = "instance"
    static let floors = "floors"
    static let currentFloor = "current floor number"
    static let placedAccessories = "placed accessories"
    static let uniqueIdentifier = "identifier"
    static let floorNumber = "floor number"
    static let etage = "etage"
}

enum FacilityError: Error {
    case floorNotFound
    case actionFailed(error: Error)
}

/*
struct Coordinate {
    var x: Int
    var y: Int
}
*/
