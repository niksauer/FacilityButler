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
    case readCharacteristicFailed(error: Error)
    case enableCharacteristicNotificationFailed(error: Error)
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
            message = NSLocalizedString("Please select or create a facility for continued use.", comment: "error select or create facility")
        case .floorNotFound:
            message = NSLocalizedString("The requested floor couldn't be found.", comment: "error floor couldn't be found")
        case .saveFailed:
            message = NSLocalizedString("Failed to save current facility state.", comment: "error failed to save faility")
        case .actionFailed(let errorMessage):
            message = NSLocalizedString("Failed due to unexpected error: \(errorMessage)", comment: "error unexpected error")
        case .accessoryBlocked(let errorMessage):
            message = "Failed to unblock accessory due to unexpected error: \(errorMessage)"
        case .accessoryUnreachable:
            message = "Unable to communicate with accessory."
        case .serviceUnreachable:
            message = "Unable to communicate with requested accessory service."
        case .noOldValue:
            message = "Unable to retrieve current accessory state."
        case .readCharacteristicFailed(let errorMessage):
            message = "Failed to read accessory characteristic, due to unexpected error: \(errorMessage)"
        case .enableCharacteristicNotificationFailed(let errorMessage):
            message = "Failed to enable notifications for accessory characteristic, due to unexpected error: \(errorMessage)"
        }
        
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "alert box error title"), message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "alert box error dismiss"), style: .default, handler: nil)
        alert.addAction(dismissAction)
        
        viewController.present(alert, animated: true, completion: nil)
        
        return true
    } else {
        return false
    }
}



