//
//  FloorPlanController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class FloorPlanController: UIViewController, FacilityButlerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var currentFloorLabel: UILabel!
    @IBOutlet weak var currentFloorStepper: UIStepper!
    
    // MARK: - Instance Properties
    var model: FacilityButler!
    
    // MARK: - Initialization
    /// loads most recently used floor plan
    override func viewDidLoad() {
        print("test")
        currentFloorStepper.value = Double(model.facility.currentFloor)
        switchToFloor(number: model.facility.currentFloor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        model.delegate = self
    }
    
    // MARK: - Navigation
    /// loads or creates requested floor
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if let accessoryVC = destination as? AccessoryController {
            accessoryVC.model = model
        } else if let settingsVC = destination as? SettingsController {
            settingsVC.model = model
        }
    }
    
    @IBAction func goToFloor(_ sender: UIStepper) {
        let floorNumber = Int(sender.value)
        
        if model.facility.floors.contains(where: { $0.etage == floorNumber }) == false {
            let ordinalFloor = FloorPlan.getOrdinal(ofFloor: floorNumber, capitalized: false)
            
            let actionController = UIAlertController(title: "Create Floor", message: "Do you want to create the \(ordinalFloor)?", preferredStyle: .alert)
            let createAction = UIAlertAction(title: "Create", style: .default, handler: { (alertAction) in
                self.model.facility.createFloor(number: floorNumber)
                self.switchToFloor(number: floorNumber)
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
    
    // TODO: re-draw floor plan if facility has changed
    /// receives and attempts to place selected accessory
    @IBAction func unwindToFloorPlan(segue: UIStoryboardSegue) {
        if let source = segue.source as? AccessoryController, let selectedAccessory = source.list.selection {
            log.debug("unwinded to FloorPlanController from AccessoriesTableViewController")
            placeAccessory(accessory: selectedAccessory)
        }
    }

    // MARK: - Actions
    /// places accessory on current floor
    func placeAccessory(accessory: HMAccessory) {
        do {
            try model.facility.placeAccessory(accessory)
            try model.save()
        } catch {
            presentError(viewController: self, error: error)
        }
    }
    
    // TODO: draw floor plan
    /// draws requested floorplan and saves current state
    /// - Parameter number: etage to be drawn
    func switchToFloor(number: Int) {
        model.facility.currentFloor = number
        currentFloorLabel.text = "\(number)"
        navigationItem.title = FloorPlan.getOrdinal(ofFloor: number, capitalized: true)
        log.debug("switched to floor #\(number) with accessoires \(model.facility.getPlacedAccessories(ofFloor: number))")
        
        do {
            try model.save()
        } catch {
            presentError(viewController: self, error: error)
        }
    }

    // MARK: - Facility Butler Delegate
    func didUpdateFacility(isSet: Bool) {
        if isSet {
            currentFloorStepper.value = Double(model.facility.currentFloor)
            switchToFloor(number: model.facility.currentFloor)
        }
    }
    
}
