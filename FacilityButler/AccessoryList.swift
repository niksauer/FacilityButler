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
    
    // MARK: - Instance Properties
    let configuredSection = NSLocalizedString("not placed", comment: "configured section title")
    let unconfiguredSection = NSLocalizedString("newly discovered", comment: "unconfigured section title")
    var sectionTitles: [String]
    var accessories = Array(repeating: [HMAccessory](), count: 2)
    let accessoryBrowser = HMAccessoryBrowser()
    var selection: HMAccessory?
    
    // MARK: - Initialization
    /// allows rearrangement of sections
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
