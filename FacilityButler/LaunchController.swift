//
//  LaunchController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 01.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

var facility: Facility!

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
    
    // MARK: - Navigation
    
    // MARK: - Home Manager Delegate
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if facility == nil, let primaryHome = manager.primaryHome {
            if let savedFacility = Facility.loadFacility(identifier: primaryHome.uniqueIdentifier) {
                facility = savedFacility
                log.debug("Loaded previously saved facility \(facility) of instance \(facility.instance) with accessories \(facility.instance.accessories)")
            } else {
                facility = Facility(home: primaryHome)
                log.debug("Created new facility \(facility) of instance \(facility.instance) with accessories \(facility.instance.accessories)")
            }
            
            enterButton.isEnabled = true
//            performSegue(withIdentifier: "ShowFloorPlan", sender: self)
        } else {
            enterButton.isEnabled = false
            log.warning("No primary home set, please create or select home from settings")
//            performSegue(withIdentifier: "CreateFacility", sender: self)
        }
    }
    
}
