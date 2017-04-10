//
//  DrawView.swift
//  FacilityButler
//
//  Created by Malcolm Malam on 06.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class DrawView: UIView {

    // MARK: - Instance Properties
    var delegate : DrawViewDelegate?
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    
    // creating an array of lines which will be drawn in the function draw(_:)
    var lines: [Line] = []
    
    var didClear = false
    var lastLines = [Line]()
    
    // 2 boolean variables in order to draw vertically or horizontally
    var drawVertical: Bool! = true
    var drawDiagonal: Bool! = false
    
    // boolean variable to determine if the Line is the firstLine on the Canvas
    var firstLine: Bool! = true
    
    // MARK: - Actions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if it is the first line to be drawn then assign the coordinates of the first touch to firstPoint
        if firstLine {
            firstPoint = touches.first?.location(in: self)
            // after we assigned our first touch, firstLine is set to be false in order to draw only appending lines (seen later)
            firstLine = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // last point gets the value of the last point we touched
        lastPoint = touches.first?.location(in: self)
        
        let (initialPoint, endPoint) = getLine(firstPoint: firstPoint, lastPoint: lastPoint)
        lines.append(Line(start: initialPoint, end: endPoint))
        firstPoint = endPoint
        delegate?.didDrawLine()
        lastLines.removeAll()
        checkIfSingleLineDrawn()
        
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        
        if (firstPoint != nil) {
            for line in lines{
                context?.move(to: line.start)
                context?.addLine(to: line.end)
                context?.setLineWidth(5)
                context?.setStrokeColor(UIColor.black.cgColor)
                context?.setLineCap(CGLineCap.round)
                context?.strokePath()
                
            }
        }
    }
    
    /* first we set the boolean variable didClear to false because we didnt clear the canvas then we enable the redo button, then we delete the last element of the lines array and safe it in a new array "lastLines"
     then we have to update our new ending point which ist the end of the new last element of the line array.
     then we redraw everything, after that we check if the line array is empty (did we delete the last element of the array)
     if the array is empty then we disable the undo and clear button */
    func undo() {
        didClear = false
        lastLines.append(lines.popLast()!)
        firstPoint = lines.last?.end
        setNeedsDisplay()
        checkIfSingleLineDrawn()
    }
    
    /* first we ask wether we clear the canvas or iv we've undone the last drawn line.
     !didClear: we insert the last element of the last deleted lines array in our lines array.
     didClear: we assign every line we deleted to the lines array then we check if we have only redrawn one line and set the undo button accordingly then we assign endpoint of the last element of lastLines array to the firstPoint  then we delete everything in lastLines because we've already redone everything there was
     
     Then we enable clear button because there are lines that can be cleared.
     if there are no more lines to be redone then we disable the redo button.
     Then we set the Boolean variable firstLine to false to signal that we dont draw the first line
     then we set did clear to false again
     then we redraw */
    func redo() {
        if !didClear {
            lines.append(lastLines.removeLast())
        } else {
            lines = lastLines
            firstPoint = lastLines.last?.end
            lastLines.removeAll()
        }
        
        firstLine = false
        didClear = false
        setNeedsDisplay()
        checkIfSingleLineDrawn()
    }
    
    /* when clearButton is triggered we set didClear to true and we save everything we are going to delete in the last lines array
     the array of lines is resetted the boolean to determine wether we draw the first line is
     set to true and the clear and undo button is disabled because you can't clear a blank canvas
     then the redo button is enabled if we decide to redraw all lines we deleted (in redo())
     then we force the drawTool to redraw the empty line array with setNeedsDisplay() */
    func clear() {
        didClear = true
        lastLines = lines
        lines = []
        firstLine = true
        setNeedsDisplay()
    }
    
    // MARK: - Private Actions
    
    /* Workaround: we couldn't redraw if we deletet all lines with 'undo'
     solution if we disable undo if there is only one line left everything works fine */
    private func checkIfSingleLineDrawn() {
        if lines.count == 1 {
            delegate?.shouldSetUndoButton(false)
        } else {
            delegate?.shouldSetUndoButton(true)
        }
    }
    
    private func getLine(firstPoint fp: CGPoint, lastPoint lp: CGPoint) -> (CGPoint, CGPoint) {
        var newLastPoint: CGPoint = CGPoint(x: 0, y: 0)
        
        if (drawVertical && !drawDiagonal) {
            // vertically
            newLastPoint = CGPoint(x: fp.x, y: lp.y)
        } else if (!drawVertical && !drawDiagonal) {
            // horizontally
            newLastPoint = CGPoint(x: lp.x, y: fp.y)
        } else {
            // 45 degrees (x coordinate from firstpoint + the distance to the lastpoint on the x-axis ... same with y
            if (lp.x < fp.x) {
                newLastPoint = CGPoint(x: fp.x - abs(lp.y - fp.y), y: lp.y)
            } else if (lp.x > fp.x) {
                newLastPoint = CGPoint(x: fp.x + abs(lp.y - fp.y), y: lp.y)
            }
        }
        
        return (fp,newLastPoint)
    }

}

protocol DrawViewDelegate {
    func didDrawLine()
    func shouldSetUndoButton(_ state: Bool)
}
