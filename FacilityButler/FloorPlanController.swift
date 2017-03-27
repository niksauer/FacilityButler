//
//  ViewController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit
import os.log

class FloorPlanController: UIViewController {
    // MARK: - Outlets
    
    // MARK: - Instance Properties
    var placedAccessoires: [HMAccessory]?
    
    // MARK: - Navigation
    // TODO: - Let user place accessory on floor plan
    @IBAction func unwindToFloorPlan(segue: UIStoryboardSegue) {
        if let source = segue.source as? AccessoriesTableViewController, let selectedAccessory = source.list.selection.accessory {
            placedAccessoires?.append(selectedAccessory)
            os_log("Received accessory: %@", log: OSLog.default, type: .debug, selectedAccessory as CVarArg)
        } else {
            os_log("No accessory selection", log: OSLog.default, type: .debug)
        }
    }
    
    // MARK: - Actions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
