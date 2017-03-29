//
//  FloorPlan.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 28.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import Foundation
import HomeKit

class FloorPlan {
    // MARK: - Instance Properties
    let etage: Int
    let name: String?
    var accessoires = [HMAccessory]()
    
    // MARK: - Initialization
    init(etage: Int) {
        self.etage = etage
        self.name = nil
    }
    
    init(etage: Int, name: String) {
        self.etage = etage
        self.name = name
    }
}
