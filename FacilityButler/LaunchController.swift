//
//  LaunchController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 01.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class LaunchController: UIViewController, HMHomeManagerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: - Instance Properties
    let manager = HMHomeManager()
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
    }
    
    // MARK: - Home Manager Delegate
    
    // INFO:
    // sets and transitions to current facility, either by loading previously saved configuration or creating new instance
    // both requiring presence of primary HMHOME, otherwise user will be directed to create new home
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if facility == nil, instance == nil, let primaryHome = manager.primaryHome {
            instance = primaryHome
            log.info("Home \(instance!) has acessories \(instance!.accessories)")
            
            if let savedFacility = Facility.loadFacility(identifier: primaryHome.uniqueIdentifier.uuidString) {
                facility = savedFacility
            } else {
                facility = Facility()
            }
            
    
            enterButton.isEnabled = true
            performSegue(withIdentifier: "showFloorPlan", sender: self)
        } else {
            enterButton.isEnabled = false
            log.warning("No primary home set, please create or select home from settings")
            performSegue(withIdentifier: "createFacility", sender: self)
        }
    }
    
}
