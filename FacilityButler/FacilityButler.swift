//
//  FacilityButler.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 05.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class FacilityButler {
    
    // MARK: Instance Properties
    var facility: Facility!
    var instance: HMHome!
    let butler = HMHomeManager()
    var isSet = false
    
    // MARK: - Actions
    // sets and transitions to current facility, either by loading previously saved configuration or creating new one
    // both requiring network presence of primary home, otherwise user will be directed to settings to create new home
    func setup() {
        guard !isSet else {
            return
        }
        
        if let primaryHome = butler.primaryHome {
            loadFacility(ofInstance: primaryHome)
            log.info("Home \(instance!) has acessories \(instance!.accessories)")
            isSet = true
        } else {
            log.warning("No primary home set, please create or select home from settings")
        }
    }
    
    func createFacility(name: String, completion: @escaping (Error?) -> Void) {
        createInstance(name: name, completion: { (error) in
            completion(error)
        })
    }
    
    func deleteFacility(home: HMHome, completion: @escaping (Error?) -> Void) {
        let wasPrimaryHome = home.isPrimary
        
        deleteInstance(home: home, completion: { (error) in
            if error == nil, wasPrimaryHome {
                if let newPrimaryHome = self.butler.primaryHome {
                    self.loadFacility(ofInstance: newPrimaryHome)
                } else {
                    self.instance = nil
                    self.facility = nil
                    log.info("No facilities available")
                }
            }
            
            completion(error)
        })
    }

    func setCurrentFacility(home: HMHome, completion: @escaping (Error?) -> Void) {
        if !home.isPrimary {
            butler.updatePrimaryHome(home, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.info("Failed to update primary home due to: \(error)")
                    completion(error)
                } else {
                    self.loadFacility(ofInstance: home)
                    completion(nil)
                }
            })
        } else {
            log.debug("Selected facility is already primary")
        }
    }
    
    // MARK: - Private Actions
    private func createInstance(name: String, completion: @escaping (Error?) -> Void) {
        butler.addHome(withName: name, completionHandler: { (home, errorMessage) in
            if let error = errorMessage {
                log.error("failed to create home \(name)")
                completion(FacilityError.actionFailed(error: error))
            } else if let home = home {
                log.info("created home \(home)")
                completion(nil)
            }
        })
    }
    
    private func deleteInstance(home: HMHome, completion: @escaping (Error?) -> Void) {
        if butler.homes.contains(home) {
            butler.removeHome(home, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error("failed to delete home \(home)")
                    completion(FacilityError.actionFailed(error: error))
                } else {
                    log.info("deleted home \(home)")
                    completion(nil)
                }
            })
        } else {
            log.debug("home \(home) does not exist, cancelling deletion")
        }
    }
    
    private func loadFacility(ofInstance home: HMHome) {
        let identifier = home.uniqueIdentifier.uuidString
        let archiveURL = DocumentsDirectory.appendingPathComponent("facility_\(identifier)")
        
        self.instance = home
        log.info("Updated primary home to \(instance) with accessories \(instance.accessories)")
        
        if let savedFacility = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? Facility {
            self.facility = savedFacility
        } else {
            self.facility = Facility()
        }
    }
    
}
