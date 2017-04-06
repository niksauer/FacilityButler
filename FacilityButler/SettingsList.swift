//
//  SettingsList.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 04.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation

class SettingsList {
    
    // MARK: - Instance Properties
    let homeSection = "my facilities"
    let designSection = "look & feel"
    var sectionTitles: [String]
    var primaryFacility: IndexPath?
    
    // MARK: - Initialization
    /// allows rearrangement of sections without changing code references
    init() {
        sectionTitles = [homeSection, designSection]
    }

}
