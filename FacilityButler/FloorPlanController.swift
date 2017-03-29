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
    @IBOutlet weak var currentFloor: UILabel!
    
    // MARK: - Instance Properties
    let home = Home()
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    @IBAction func goToFloor(_ sender: UIStepper) {
        let floorNumber = Int(sender.value)
        
        if home.floors.contains(where: { $0.etage == floorNumber }) == false {
            let ordinalFloor = FloorPlan.getOrdinalFloorNumber(of: floorNumber, capitalized: false)
            
            let actionController = UIAlertController(title: "Create Floor", message: "Do you want to create the \(ordinalFloor)?", preferredStyle: .alert)
            let createAction = UIAlertAction(title: "Create", style: .default, handler: { (alertAction) in
                self.home.createFloor(number: floorNumber)
                self.switchToFloor(number: floorNumber)
            })
            let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                sender.value = floorNumber >= 0 ? Double(floorNumber-1) : (Double(floorNumber+1))
            })
            
            actionController.addAction(createAction)
            actionController.addAction(dismissAction)
            present(actionController, animated: true, completion: nil)
        } else {
            switchToFloor(number: floorNumber)
        }
    }
    
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
//                os_log("Prepared AccessoriesTableViewController", log: OSLog.default, type: .debug)
            }
        }
    }
    
    // MARK: - Actions
    func placeAccessory(accessory: HMAccessory) {
        do {
            try home.placeAccessory(accessory)
//            os_log("Placed accessory: %@ on current floor #%@", log: OSLog.default, type: .debug, accessory as CVarArg, home.currentFloor)
        } catch HomeError.floorNotFound {
//            os_log("Can't find floor #%@, cancelling placement", log: OSLog.default, type: .debug, home.currentFloor)
        } catch HomeError.alreadyPlaced {
//            os_log("Accessory already placed on current floor", log: OSLog.default, type: .debug)
        } catch {
            
        }
    }
    
    // MARK: - Private Action
    private func switchToFloor(number: Int) {
        currentFloor.text = "\(number)"
        navigationItem.title = FloorPlan.getOrdinalFloorNumber(of: number, capitalized: true)
//        os_log("Switched to floor: %@", log: OSLog.default, type: .debug, number as CVarArg)
    }
}
