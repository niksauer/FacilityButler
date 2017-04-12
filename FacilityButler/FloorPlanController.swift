//
//  FloorPlanController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class FloorPlanController: UIViewController, FacilityButlerDelegate, DrawViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var currentFloorLabel: UILabel!
    @IBOutlet weak var currentFloorStepper: UIStepper!
    @IBOutlet weak var addAccessoryButton: UIBarButtonItem!
    
    // MARK: - Instance Properties
    var model: FacilityButler!
    var isInitialSetup = true
    var isUIEnabled = false {
        didSet {
            if isUIEnabled {
                addAccessoryButton.isEnabled = true
                currentFloorStepper.isEnabled = true
                drawTool.isUserInteractionEnabled = true
            } else {
                addAccessoryButton.isEnabled = false
                currentFloorStepper.isEnabled = false
                drawTool.isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: - Initialization
    override func viewWillAppear(_ animated: Bool) {
        model.delegate = self
        drawTool.delegate = self
    }
    
    // MARK: - Navigation
    /// loads or creates requested floor
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if model.instance != nil {
            model.facility.setBlueprint(drawTool.getContent())
        }
        
        let destination = segue.destination
    
        if let navController = destination as? UINavigationController, let accessoryVC = navController.topViewController as? AccessoryController {
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
                self.model.facility.setBlueprint(self.drawTool.getContent())
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
            self.model.facility.setBlueprint(drawTool.getContent())
            switchToFloor(number: floorNumber)
        }
    }
    
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
    
    /// draws requested floorplan
    /// - Parameter number: etage to be drawn
    func switchToFloor(number: Int) {
        model.facility.currentFloor = number
        
        currentFloorLabel.text = "\(number)"
        navigationItem.title = FloorPlan.getOrdinal(ofFloor: number, capitalized: true)
        log.debug("switched to floor #\(number) with accessoires \(model.facility.getPlacedAccessories(ofFloor: number))")
        
        drawTool.setContent(blueprint: model.facility.getBlueprint())
    }

    // MARK: - Facility Butler Delegate
    // TODO: handle no facility situation
    /// loads most recently used floor plan
    func didUpdateFacility(isSet: Bool) {
        if isSet {
            isUIEnabled = true
            currentFloorStepper.value = Double(model.facility.currentFloor)
            switchToFloor(number: model.facility.currentFloor)
        } else {
            isUIEnabled = false
            
//            if isInitialSetup {
//                presentError(viewController: self, error: FacilityError.noFaciltiySet)
//            }
            
            isInitialSetup = false
        }
    }
    
    
    
    
    // MARK: - Custom Draw Tool
    // MARK: Instance Properties
    var didMakeChange = false
    var saveTimer: Timer?
    
    // MARK: Outlets
    @IBOutlet var drawTool: DrawView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var lineTypeLabel: UILabel!
    @IBOutlet weak var diagonalLabel: UILabel!
    
    // MARK: Actions
    func startSaveTimer() {
        saveTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            guard self.model.instance != nil else {
                return
            }
            
            if self.didMakeChange {
                do {
                    self.model.facility.setBlueprint(self.drawTool.getContent())
                    try self.model.save()
                } catch {
                    presentError(viewController: self, error: error)
                }
                
                self.didMakeChange = false
            } else {
                log.debug("no change made in past 5 seconds, stopping save timer")
                self.saveTimer?.invalidate()
            }
        })
    }
    
    /// If the switch is on we set the vertical boolean true vice versa at the same time we change the text of the label
    @IBAction func switchLineType(_ sender: UISwitch) {
        if sender.isOn {
            lineTypeLabel.text = "Vertical"
            drawTool.drawVertical = true
        } else {
            lineTypeLabel.text = "Horizontal"
            drawTool.drawVertical = false
        }
    }
    
    /// if our diagonal switch is on we set the boolean value and set the color of the text lables accordingly
    @IBAction func useDiagonals(_ sender: UISwitch) {
        if sender.isOn {
            diagonalLabel.textColor = UIColor.black
            lineTypeLabel.textColor = UIColor.lightGray
            drawTool.drawDiagonal = true
        } else {
            lineTypeLabel.textColor = UIColor.black
            diagonalLabel.textColor = UIColor.lightGray
            drawTool.drawDiagonal = false
        }
    }
    
    @IBAction func undo(_ sender: UIBarButtonItem) {
        drawTool.undo()
        redoButton.isEnabled = true
    }

    @IBAction func redo(_ sender: UIBarButtonItem) {
        drawTool.redo()
        clearButton.isEnabled = true
    }
    
    @IBAction func clear(_ sender: UIBarButtonItem) {
        drawTool.clear()
        doneButton.isEnabled = false
        clearButton.isEnabled = false
        undoButton.isEnabled = false
        redoButton.isEnabled = true
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        drawTool.done()
    }
    
    // MARK: Draw View Delegate
    /* if we draw a line we enable clear and disable redo, because we dont want to redo something if we decided to draw something else 
        if the user has drawn at least 3 lines he can finish his masterpiece*/
    func didDrawLine() {
        clearButton.isEnabled = true
        redoButton.isEnabled = false
        
        didMakeChange = true
        log.debug("made change to floorplan, (re-)starting save timer")
        startSaveTimer()
    }
    
    func shouldSetUndoButton(_ state: Bool) {
        undoButton.isEnabled = state
    }
    
    func shouldSetRedoButton(_ state: Bool) {
        redoButton.isEnabled = state
    }
    
    func shouldSetClearButton(_ state: Bool) {
        clearButton.isEnabled = state
    }
    
    func shouldSetDoneButton(_ state: Bool) {
        doneButton.isEnabled = state
    }
    
    
    
}
