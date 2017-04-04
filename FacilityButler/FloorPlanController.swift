//
//  FloorPlanController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class FloorPlanController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var currentFloorLabel: UILabel!
    @IBOutlet weak var currentFloorStepper: UIStepper!
    
    // MARK: - Initialization
    // TODO: load appropriate floor, i.e. facility.currentFloor
    override func viewDidLoad() {
        currentFloorStepper.value = Double(facility.currentFloor)
        switchToFloor(number: facility.currentFloor)
    }
    
    // MARK: - Navigation
    @IBAction func goToFloor(_ sender: UIStepper) {
        let floorNumber = Int(sender.value)
        
        if facility.floors.contains(where: { $0.etage == floorNumber }) == false {
            let ordinalFloor = FloorPlan.getOrdinalFloorNumber(of: floorNumber, capitalized: false)
            
            let actionController = UIAlertController(title: "Create Floor", message: "Do you want to create the \(ordinalFloor)?", preferredStyle: .alert)
            let createAction = UIAlertAction(title: "Create", style: .default, handler: { (alertAction) in
                facility.createFloor(number: floorNumber)
                self.switchToFloor(number: floorNumber)
                
                do {
                    try facility.save()
                } catch {
                    
                }
            })
            let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
                sender.value = floorNumber >= 0 ? Double(floorNumber-1) : (Double(floorNumber+1))
                log.debug("dismissed create floor alert")
            })
            
            actionController.addAction(createAction)
            actionController.addAction(dismissAction)
            present(actionController, animated: true, completion: nil)
        } else {
            switchToFloor(number: floorNumber)
        }
    }
    
    @IBAction func unwindToFloorPlan(segue: UIStoryboardSegue) {
        if let source = segue.source as? AccessoryController, let selectedAccessory = source.list.selection.accessory {
            log.debug("unwinded to FloorPlanController from AccessoriesTableViewController")
            placeAccessory(accessory: selectedAccessory)
        }
    }

    // MARK: - Actions
    // TODO: save facility after placement
    func placeAccessory(accessory: HMAccessory) {
        do {
            try facility.placeAccessory(accessory)
            try facility.save()
        } catch {
            
        }
    }
    
    // TODO: re-draw floor plan after switching
    func switchToFloor(number: Int) {
        facility.currentFloor = number
        currentFloorLabel.text = "\(number)"
        navigationItem.title = FloorPlan.getOrdinalFloorNumber(of: number, capitalized: true)
        log.debug("switched to floor #\(number) with accessoires \(facility.getPlacedAccessoriesOfFloor(number))")
    }
    
}
