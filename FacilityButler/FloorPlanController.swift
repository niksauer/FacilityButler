//
//  ViewController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class FloorPlanController: UIViewController, HMHomeManagerDelegate {
    // MARK: - Outlets
    @IBOutlet var currentFloor: UILabel!
    
    // MARK: - Instance Properties
    var home: Facility?
    let homeManager = HMHomeManager()
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager.delegate = self
    }
    
    // MARK: - Navigation
    @IBAction func goToFloor(_ sender: UIStepper) {
        guard homeIsSet() else {
            return
        }
        
        let floorNumber = Int(sender.value)
        
        if home!.floors.contains(where: { $0.etage == floorNumber }) == false {
            let ordinalFloor = FloorPlan.getOrdinalFloorNumber(of: floorNumber, capitalized: false)
            
            let actionController = UIAlertController(title: "Create Floor", message: "Do you want to create the \(ordinalFloor)?", preferredStyle: .alert)
            let createAction = UIAlertAction(title: "Create", style: .default, handler: { (alertAction) in
                self.home!.createFloor(number: floorNumber)
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
    
    @IBAction func unwindToFloorPlan(segue: UIStoryboardSegue) {
        if let source = segue.source as? AccessoryListController, let selectedAccessory = source.list.selection.accessory {
            log.debug("unwinded to FloorPlanController from AccessoriesTableViewController")
            placeAccessory(accessory: selectedAccessory)
        }
    }
    
    // INFO: - prepares destination view controller data before transitioning to it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAccessory" {
            if let accessoriesTable = segue.destination.childViewControllers[0] as? AccessoryListController, let placed = home?.getPlacedAccessoires() {
                accessoriesTable.list.placedAccessories = placed
                log.debug("setup AccessoryListController with currently placed accessoires \(placed)")
            }
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Private Action
    private func placeAccessory(accessory: HMAccessory) {
        guard homeIsSet() else {
            return
        }
        
        do {
            try home!.placeAccessory(accessory)
        } catch FacilityError.floorNotFound {
            
        } catch {
            
        }
    }
    
    private func switchToFloor(number: Int) {
        guard homeIsSet() else {
            return
        }
        
        home!.currentFloor = number
        currentFloor.text = "\(number)"
        navigationItem.title = FloorPlan.getOrdinalFloorNumber(of: number, capitalized: true)
        log.debug("switched to floor #\(number) with accessoires \(home!.getPlacedAccessoriesOfFloor(number))")
    }
    
    private func homeIsSet() -> Bool {
        if home != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Home Manager Delegate
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if homeIsSet() == false, let home = Facility(manager: manager) {
            self.home = home
        }
    }
}
