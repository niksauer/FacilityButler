//
//  FacilityButler.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 05.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class FacilityButler: NSObject, HMHomeManagerDelegate {
    
    // MARK: - Instance Properties
    var facility: Facility!
    var instance: HMHome!
    let butler = HMHomeManager()
    var isInitialSetup = true
    var delegate: FacilityButlerDelegate?
    
    let primaryFunction = [
        HMAccessoryCategoryTypeLightbulb : [HMServiceTypeLightbulb, HMCharacteristicTypePowerState]
    ]
    
    // MARK: - Initialization
    override init() {
        super.init()
        butler.delegate = self
    }
    
    // MARK: - Actions
    func createFacility(name: String, completion: @escaping (Error?) -> Void) {
        createInstance(name: name, completion: { (home, error) in
            if error == nil, self.butler.homes.count == 1 {
                self.instance = home!
                self.loadFacility(ofInstance: home!)
            }
            
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
                    self.delegate?.didUpdateFacility(isSet: false)
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
    
    func save() throws {
        let archiveURL = DocumentsDirectory.appendingPathComponent("facility_\(instance.uniqueIdentifier)")
        
        if NSKeyedArchiver.archiveRootObject(facility as Any, toFile: archiveURL.path) {
            log.debug("Saved current state")
        } else {
            log.error("Failed to save current state")
            throw FacilityError.saveFailed
        }
    }
    
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
    
    func unblockAccessory(_ accessory: HMAccessory, completion: @escaping (Error?) -> Void) {
        instance.unblockAccessory(accessory, completionHandler: { (errorMessage) in
            if let error = errorMessage {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
    
    // MARK: - Private Actions
    private func createInstance(name: String, completion: @escaping (HMHome?, Error?) -> Void) {
        butler.addHome(withName: name, completionHandler: { (home, errorMessage) in
            if let error = errorMessage {
                log.error("failed to create home \(name)")
                completion(nil, FacilityError.actionFailed(error: error))
            } else if let home = home {
                log.info("created home \(home)")
                completion(home, nil)
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
        log.info("Updated primary facility to \(instance!) with accessories \(instance.accessories)")
        
        if let savedFacility = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? Facility {
            self.facility = savedFacility
        } else {
            self.facility = Facility()
        }
        
        delegate?.didUpdateFacility(isSet: true)
    }
    
    // MARK: - Home Manager Delegate
    /// transitions to most recently used facility or requires user to create new facility in settings
    /// dis/enables trepassing buttons accordingly
    /// - Parameter manager: network discovery agent for HMHome(s)
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        guard isInitialSetup else {
            return
        }
        
        if let primaryHome = manager.primaryHome {
            loadFacility(ofInstance: primaryHome)
            isInitialSetup = false
        } else {
            delegate?.didUpdateFacility(isSet: false)
            log.warning("No primary home set, please create or select home from settings")
        }
    }
    
}

protocol FacilityButlerDelegate {
    func didUpdateFacility(isSet: Bool)
}
