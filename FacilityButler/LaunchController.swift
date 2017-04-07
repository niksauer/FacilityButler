//
//  LaunchController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 01.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class LaunchController: UIViewController, FacilityButlerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: - Instance Properties
    var model: FacilityButler!
    
    // MARK: - Initialization
    override func viewWillAppear(_ animated: Bool) {
        model.delegate = self
        log.debug("LaunchController is model delegate")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if let floorPlanVC = destination as? FloorPlanController {
            floorPlanVC.model = model
            log.debug("Setup floor plan view controller")
        } else if let settingsVC = destination as? SettingsController {
            settingsVC.model = model
            log.debug("Setup settings view controller")
        }
    }
    
    // MARK: - Facility Butler Delegate
    func didUpdateFacility(isSet: Bool) {
        if isSet {
            enterButton.isEnabled = true
        } else {
            enterButton.isEnabled = false
        }
    }
    
}
