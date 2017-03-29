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
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    @IBAction func unwindToFloorPlan(segue: UIStoryboardSegue) {
        if let source = segue.source as? AccessoriesTableViewController, let selectedAccessory = source.list.selection.accessory {
            placeAccessory(accessory: selectedAccessory)
        }
    }
    
    // INFO: - prepares destination view controller data before transitioning to it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAccessory" {
            if let accessoriesTable = segue.destination.childViewControllers[0] as? AccessoriesTableViewController {
                accessoriesTable.list.placedAccessories.append(contentsOf: home.getPlacedAccessoires())
                os_log("Prepared AccessoriesTableViewController", log: OSLog.default, type: .debug)
            }
        }
    }
    
    // MARK: - Actions
    func placeAccessory(accessory: HMAccessory) {
        do {
            try home.placeAccessory(accessory)
            os_log("Placed accessory: %@ on current floor #%@", log: OSLog.default, type: .debug, accessory as CVarArg, home.currentFloor)
        } catch HomeError.floorNotFound {
            os_log("Can't find floor #%@, cancelling placement", log: OSLog.default, type: .debug, home.currentFloor)
        } catch HomeError.alreadyPlaced {
            os_log("Accessory already placed on current floor", log: OSLog.default, type: .debug)
        } catch {
            
        }
    }
}
