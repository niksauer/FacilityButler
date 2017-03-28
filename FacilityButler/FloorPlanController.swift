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
    let home = Home()
    
    // MARK: - Navigation
    // TODO: - Let user place accessory on floor plan
    @IBAction func unwindToFloorPlan(segue: UIStoryboardSegue) {
        if let source = segue.source as? AccessoriesTableViewController, let selectedAccessory = source.list.selection.accessory {
            os_log("Received accessory: %@", log: OSLog.default, type: .debug, selectedAccessory as CVarArg)
            placeAccessory(accessory: selectedAccessory)
        }
    }
    
    // MARK: - Actions
    override func viewDidLoad() {
        print(home.placedAccessories)
        super.viewDidLoad()
    }
    
    // MARK: - Private Actions
    func placeAccessory(accessory: HMAccessory) {
//        placedAccessoires?.append(accessory)
//        let button = UIButton(type: .roundedRect)
//        button.setTitle(accessory.name, for: .normal)
//        view.addSubview(button)
//        os_log("Placed accessory: %@", log: OSLog.default, type: .debug, accessory as CVarArg)
    }
}
