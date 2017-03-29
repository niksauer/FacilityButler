//
//  AccessoryList.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 27.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit
import os.log

class AccessoryList {
    // MARK: - Properties
    let configuredSection = "not placed"
    let unconfiguredSection = "newly discovered"
    var sectionTitles: [String]
    
    var accessories = Array(repeating: [HMAccessory](), count: 2)
    var placedAccessories = [HMAccessory]()
    var selection = selectedAccessory()
    
    let accessoryBrowser = HMAccessoryBrowser()
    
    // MARK: - Data Structures
    struct selectedAccessory {
        var accessory: HMAccessory?
        var indexPath: IndexPath?
    }
    
    // MARK: - Initialization
    // INFO: - for possible rearrangement of sections
    init() {
        sectionTitles = [configuredSection, unconfiguredSection]
    }
    
    // MARK: - Actions
    func startAccessoryScan () {
        accessoryBrowser.startSearchingForNewAccessories()
        log.info("started network scan")
    }
    
    func stopAccessoryScan() {
        accessoryBrowser.stopSearchingForNewAccessories()
        log.info("stopped network scan")
    }
    
    // INFO: - return row index for use as indexPath
    @discardableResult func insertIntoSection(_ section: Int, accessory: HMAccessory) -> Int {
        accessories[section].append(accessory)
        log.debug("inserted accessory \(accessory) into section \(section)")
        return accessories[section].endIndex-1
    }
    
    @discardableResult func removeFromSection(_ section: Int, accessory: HMAccessory) -> Int {
        let row = accessories[section].index(of: accessory)!
        accessories[section].remove(at: row)
        log.debug("removed accessory \(accessory) from section \(section)")
        return row
    }
}
