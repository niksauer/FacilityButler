//
//  AccessoryList.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 27.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class AccessoryList {
    
    // MARK: - Properties
    let configuredSection = "not placed"
    let unconfiguredSection = "newly discovered"
    var sectionTitles: [String]
    
    var accessories = Array(repeating: [HMAccessory](), count: 2)
    var selection = selectedAccessory()
    
    let accessoryBrowser = HMAccessoryBrowser()
    
    // MARK: - Types
    struct selectedAccessory {
        var accessory: HMAccessory?
        var indexPath: IndexPath?
    }
    
    // MARK: - Initialization
    // INFO: for possible rearrangement of sections
    init() {
        sectionTitles = [configuredSection, unconfiguredSection]
    }
    
    // MARK: - Actions
    func startAccessoryScan () {
        accessoryBrowser.startSearchingForNewAccessories()
        log.debug("started network scan")
    }
    
    func stopAccessoryScan() {
        accessoryBrowser.stopSearchingForNewAccessories()
        log.debug("stopped network scan")
    }
    
    // INFO: returns row index for use as indexPath
    @discardableResult func insertIntoSection(_ section: Int, accessory: HMAccessory) -> Int {
        accessories[section].append(accessory)
        return accessories[section].endIndex-1
    }
    
    @discardableResult func removeFromSection(_ section: Int, accessory: HMAccessory) -> Int {
        let row = accessories[section].index(of: accessory)!
        accessories[section].remove(at: row)
        return row
    }
    
}
