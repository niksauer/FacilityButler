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
    let homeSection = NSLocalizedString("my facilities", comment: "list of facilities")
    let designSection = NSLocalizedString("look & feel", comment: "options for look and optics")
    var sectionTitles: [String]
    var primaryFacility: IndexPath?
    
    // MARK: - Initialization
    /// allows rearrangement of sections
    init() {
        sectionTitles = [homeSection, designSection]
    }

}
