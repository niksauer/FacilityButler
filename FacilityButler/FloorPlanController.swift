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
            let state = isUIEnabled ? "enabled" : "disabled"
            log.debug("UI is \(state)")
            
            if isUIEnabled {
                addAccessoryButton.isEnabled = true
                currentFloorStepper.isEnabled = true
            } else {
                addAccessoryButton.isEnabled = false
                currentFloorStepper.isEnabled = false
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
        let destination = segue.destination
    
        if let navController = destination as? UINavigationController, let accessoryVC = navController.topViewController as? AccessoryController {
            accessoryVC.model = model
        } else if let settingsVC = destination as? SettingsController {
            settingsVC.model = model
        }
    }
    
    func goToFloor(_ sender: UIStepper) {
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
    /// loads most recently used floor plan
    func didUpdateFacility(isSet: Bool) {
        if isSet {
            isUIEnabled = true
            currentFloorStepper.value = Double(model.facility.currentFloor)
            switchToFloor(number: model.facility.currentFloor)
        } else {
            isUIEnabled = false
            
            if isInitialSetup {
                presentError(viewController: self, error: FacilityError.noFaciltiySet)
            }
        }
    }
    
    // MARK: - custom draw tool
    @IBOutlet var drawTool: DrawView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    @IBOutlet weak var lineTypeLabel: UILabel!
    @IBOutlet weak var diagonalLabel: UILabel!
    
    var lastLines = [Line]()
    var didClear = false
    
    /* when clearButton is triggered we set didClear to true and we save everything we are going to delete in the last lines array
     the array of lines is resetted the boolean to determine wether we draw the first line is
     set to true and the clear and undo button is disabled because you can't clear a blank canvas
     then the redo button is enabled if we decide to redraw all lines we deleted (in redo())
     then we force the drawTool to redraw the empty line array with setNeedsDisplay() */
    @IBAction func clear() {
        didClear = true
        lastLines = drawTool.lines
        drawTool.lines = []
        drawTool.firstLine = true
        clearButton.isEnabled = false
        undoButton.isEnabled = false
        redoButton.isEnabled = true
        drawTool.setNeedsDisplay()
    }
    
    /* If the switch is on we set the vertical boolean true vice versa at the same time we change the text of the label  */
    @IBAction func switchLineType(_ sender: UISwitch) {
        if sender.isOn {
            lineTypeLabel.text = "Vertical lines"
            drawTool.drawVertical = true
        } else {
            lineTypeLabel.text = "Horizontal lines"
            drawTool.drawVertical = false
        }
    }
    
    /* if our diagonal switch is on we set the boolean value and set the color of the text lables accordingly */
    @IBAction func useDiagonals(_ sender: UISwitch) {
        if sender.isOn {
            diagonalLabel.textColor = UIColor.black
            diagonalLabel.textColor = UIColor.lightGray
            drawTool.drawDiagonal = true
        } else {
            lineTypeLabel.textColor = UIColor.black
            diagonalLabel.textColor = UIColor.lightGray
            drawTool.drawDiagonal = false
        }
    }
    
    /* first we set the boolean variable didClear to false because we didnt clear the canvas then we enable the redo button, then we delete the last element of the lines array and safe it in a new array "lastLines"
     then we have to update our new ending point which ist the end of the new last element of the line array.
     then we redraw everything, after that we check if the line array is empty (did we delete the last element of the array)
     if the array is empty then we disable the undo and clear button */
    @IBAction func undo(_ sender: UIBarButtonItem) {
        didClear = false
        redoButton.isEnabled = true
        lastLines.append(drawTool.lines.popLast()!)
        drawTool.firstPoint = drawTool.lines.last?.end
        checkIfFirstLineAndSetUndoButton()
        drawTool.setNeedsDisplay()
    }
    
    /* first we ask wether we clear the canvas or iv we've undone the last drawn line.
     !didClear: we insert the last element of the last deleted lines array in our lines array.
     didClear: we assign every line we deleted to the lines array then we check if we have only redrawn one line and set the undo button accordingly then we assign endpoint of the last element of lastLines array to the firstPoint  then we delete everything in lastLines because we've already redone everything there was
     
     Then we enable clear button because there are lines that can be cleared.
     if there are no more lines to be redone then we disable the redo button.
     Then we set the Boolean variable firstLine to false to signal that we dont draw the first line
     then we set did clear to false again
     then we redraw */
    @IBAction func redo(_ sender: UIBarButtonItem) {
        if !(didClear) {
            drawTool.lines.append(lastLines.removeLast())
            checkIfFirstLineAndSetUndoButton()
        } else {
            drawTool.lines = lastLines
            checkIfFirstLineAndSetUndoButton()
            drawTool.firstPoint = lastLines.last?.end
            lastLines.removeAll()
        }
        
        clearButton.isEnabled = true
        
        if lastLines.isEmpty {
            redoButton.isEnabled = false
        }
        
        drawTool.firstLine = false
        didClear = false
        drawTool.setNeedsDisplay()
    }
    
    
    // MARK: - Private Actions
    
    /* Workaround: we couldn't redraw if we deletet all lines with 'undo'
     solution if we disable undo if there is only one line left everything works fine */
    private func checkIfFirstLineAndSetUndoButton() {
        if drawTool.lines.count == 1 {
            undoButton.isEnabled = false
        } else {
            undoButton.isEnabled = true
        }
    }
    
    // MARK: - Draw View Delegate Actions
    
    /* if we draw a line we enable undo (except if there is only one line) and clear button
     we disable redo button and delete everything because we dont want to redo something if we decided to draw something
     else */
    func didDrawFirstLine() {
        checkIfFirstLineAndSetUndoButton()
        clearButton.isEnabled = true
        redoButton.isEnabled = false
        lastLines.removeAll()
    }
    
}
