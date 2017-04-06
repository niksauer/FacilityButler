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
    
    // MARK: - Initialization
    /// tells network discovery agent to redirect home results here
    override func viewDidLoad() {
        super.viewDidLoad()
        model.butler.delegate = self
    }
    
    // MARK: - Home Manager Delegate
    /// transitions to most recently used facility or requires user to create new facility in settings
    /// dis/enables trepassing buttons accordingly
    /// - Parameter manager: network discovery agent for HMHome(s)
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        model.setup()
        
        if model.isSet {
            enterButton.isEnabled = true
            performSegue(withIdentifier: "showFloorPlan", sender: self)
        } else {
            enterButton.isEnabled = false
            performSegue(withIdentifier: "createFacility", sender: self)
        }
    }
    
}
