//
//  DrawToolController.swift
//  FacilityButler
//
//  Created by Malcolm Malam on 06.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class DrawToolController: UIViewController, DrawViewDelegate {

    // MARK: - Outlets
    @IBOutlet var drawView: DrawView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var diagLabel: UILabel!
    
    // MARK: - Instance Properties
    var lastLines = [Line]()
    var didClear = false
    var delegate: DrawToolControllerDelegate?
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.delegate = self
    }

    // MARK: - Actions
    @IBAction func goToFloor(_ sender: UIStepper) {
        delegate?.didAttemptToGoToFloor(sender: sender)
    }
    
    /* when clearButton is triggered we set didClear to true and we save everything we are going to delete in the last lines array
     the array of lines is resetted the boolean to determine wether we draw the first line is
     set to true and the clear and undo button is disabled because you can't clear a blank canvas
     then the redo button is enabled if we decide to redraw all lines we deleted (in redo())
     then we force the drawView to redraw the empty line array with setNeedsDisplay() */
    @IBAction func clear() {
        didClear = true
        lastLines = drawView.lines
        drawView.lines = []
        drawView.firstLine = true
        clearButton.isEnabled = false
        undoButton.isEnabled = false
        redoButton.isEnabled = true
        drawView.setNeedsDisplay()
    }
    
    /* If the switch is on we set the vertical boolean true vice versa at the same time we change the text of the label  */
    @IBAction func switchLineType(_ sender: UISwitch) {
        if sender.isOn {
            typeLabel.text = "Vertical lines"
            drawView.drawVertical = true
        } else {
            typeLabel.text = "Horizontal lines"
            drawView.drawVertical = false
        }
    }
    
    /* if our diagonal switch is on we set the boolean value and set the color of the text lables accordingly */
    @IBAction func useDiagonals(_ sender: UISwitch) {
        if sender.isOn {
            diagLabel.textColor = UIColor.black
            typeLabel.textColor = UIColor.lightGray
            drawView.drawDiagonal = true
        } else {
            typeLabel.textColor = UIColor.black
            diagLabel.textColor = UIColor.lightGray
            drawView.drawDiagonal = false
        }
    }
    
    /* first we set the boolean variable didClear to false because we didnt clear the canvas then we enable the redo button, then we delete the last element of the lines array and safe it in a new array "lastLines"
     then we have to update our new ending point which ist the end of the new last element of the line array.
     then we redraw everything, after that we check if the line array is empty (did we delete the last element of the array)
     if the array is empty then we disable the undo and clear button */
    @IBAction func undo(_ sender: UIBarButtonItem) {
        didClear = false
        redoButton.isEnabled = true
        lastLines.append(drawView.lines.popLast()!)
        drawView.firstPoint = drawView.lines.last?.end
        checkIfFirstLineAndSetUndoButton()
        drawView.setNeedsDisplay()
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
            drawView.lines.append(lastLines.removeLast())
            checkIfFirstLineAndSetUndoButton()
        } else {
            drawView.lines = lastLines
            checkIfFirstLineAndSetUndoButton()
            drawView.firstPoint = lastLines.last?.end
            lastLines.removeAll()
        }
        
        clearButton.isEnabled = true
        
        if lastLines.isEmpty {
            redoButton.isEnabled = false
        }
        
        drawView.firstLine = false
        didClear = false
        drawView.setNeedsDisplay()
    }
    
    
    // MARK: - Private Actions
    
    /* Workaround: we couldn't redraw if we deletet all lines with 'undo'
     solution if we disable undo if there is only one line left everything works fine */
    private func checkIfFirstLineAndSetUndoButton() {
        if drawView.lines.count == 1 {
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

protocol DrawToolControllerDelegate {
    func didAttemptToGoToFloor(sender: UIStepper)
}
