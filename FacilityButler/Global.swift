//
//  Global.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 04.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

// MARK: - Global Types
struct PropertyKey {
    static let instance = "instance"
    static let floors = "floors"
    static let currentFloor = "current floor number"
    static let placedAccessories = "placed accessories"
    static let uniqueIdentifier = "identifier"
    static let floorNumber = "floor number"
    static let etage = "etage"
    static let lineStart = "start"
    static let lineEnd = "end"
    static let blueprint = "blueprint"
    static let currentTheme = "current theme"
    static let darkIcon = "is dark app icon set"
}

enum FacilityError: Error {
    case noFaciltiySet
    case floorNotFound
    case saveFailed
    case actionFailed(error: Error)
    case accessoryBlocked(error: Error)
    case accessoryUnreachable
    case serviceUnreachable
    case noOldValue
}

// MARK: - Global Methods
/// - Parameters:
///   - viewController: to present alert
///   - error: to be presented
/// - Returns: if error has been presented
@discardableResult func presentError(viewController: UIViewController, error: Error?) -> Bool {
    if let error = error as? FacilityError {
        var message: String
        
        switch error {
        case .noFaciltiySet:
            message = "Please select or create a facility for continued use."
        case .floorNotFound:
            message = "The requested floor couldn't be found."
        case .saveFailed:
            message = "Failed to save current facility state."
        case .actionFailed(let errorMessage):
            message = "Failed due to unexpected error: \(errorMessage)"
        case .accessoryBlocked(let errorMessage):
            message = "Failed to unblock accessory due to unexpected error: \(errorMessage)"
        case .accessoryUnreachable:
            message = "Unable to communicate with accessory."
        case .serviceUnreachable:
            message = "Unable to communicate with requested accessory service."
        case .noOldValue:
            message = "Unable to retrieve current accessory state."
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        
        viewController.present(alert, animated: true, completion: nil)
        
        return true
    } else {
        return false
    }
}



