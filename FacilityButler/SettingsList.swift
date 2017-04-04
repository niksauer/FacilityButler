//
//  SettingsList.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 04.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class SettingsList {
    
    // MARK: - Properties
    let homeSection = "my homes"
    let designSection = "look & feel"
    var sectionTitles: [String]
    var homes = [HMHome]()
    let homeBrowser = HMHomeManager()
    
    // MARK: - Initialization
    // INFO: for possible rearrangement of sections
    init() {
        sectionTitles = [homeSection, designSection]
    }
    
    
}
