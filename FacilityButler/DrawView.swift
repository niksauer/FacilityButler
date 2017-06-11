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
    var delegate: DrawViewDelegate?
    var strokeColor: UIColor!
    
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    
    var lines = [Line]()
    var removedLines = [Line]()
    var tempLine: Line!
    
    var didClear = false
    var didDone = false
    
    var isSwiping = false
    var isFirstLine = true
    
    var drawVertical = true
    var drawDiagonal = false

    // MARK: - UITouch Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if it is the first line to be drawn then assign the coordinates of the first touch to firstPoint
        if isFirstLine {
            firstPoint = touches.first?.location(in: self)
            
            // after we assigned our first touch, firstLine is set to be false in order to draw only appending lines (seen later)
            isFirstLine = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // while we're drawing then isSwiping is set to true
        isSwiping = true
        
        // lastpoint is initialized with the locations of your finger
        lastPoint = touches.first?.location(in: self)
        
        /* If our finger draws inside our view we create a new line which starts at the first point and ends, depending on alignment, at the returned endpoint. Then we call draw(_:). NOTE: isSwiping = true */
        if (self.bounds.contains(lastPoint)) {
            let (initialPoint, endPoint) = getLine(firstPoint: firstPoint, lastPoint: lastPoint)
            tempLine = Line(start: initialPoint, end: endPoint)
            setNeedsDisplay()
        } else {
            // if we draw outside of our view, our tempLine gets resetted
            tempLine = Line(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 0))
            setNeedsDisplay()
        }
    }
    
    /* First we set isSwiping = false because we aren't drawing anymore. Then we save the last point we touched to lastpoint. If the last point is in view then we create the line from first to, depending on alignment, the endpoint. Then we set firstPoint to this endpoint in order to start the next line from this endpoint. (Then we Tell the system that we draw a Line - UNSURE). Then we clear the array which would allow us to Redo the last line we've had undone. Then we Check wether we've drawn the firstLine. After that we can draw our line. */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSwiping = false
        lastPoint = touches.first?.location(in: self)
        
        if (self.bounds.contains(lastPoint)) {
            let (initialPoint, endPoint) = getLine(firstPoint: firstPoint, lastPoint: lastPoint)
            lines.append(Line(start: initialPoint, end: endPoint))
            firstPoint = endPoint
            
            delegate?.shouldSetClearButton(true)
            delegate?.shouldSetRedoButton(false)
            
            if lines.count > 2 {
                delegate?.shouldSetDoneButton(true)
            } else {
                delegate?.shouldSetDoneButton(false)
            }
            
            removedLines.removeAll()
            checkIfSingleLineDrawn()
            delegate?.didMakeChange()
            
            setNeedsDisplay()
        }
    }
    
    // MARK: - Custom Drawing
    override func draw(_ rect: CGRect) {
        let context = UIBezierPath()
        context.lineWidth = 4
        // UIColor.red.setFill()
        strokeColor.setStroke()
        context.lineCapStyle = .round
        context.lineJoinStyle = .round
        
        // when we're currently swiping in View then we draw our Templine
        if (isSwiping) {
            context.move(to: tempLine.start)
            context.addLine(to: tempLine.end)
            context.stroke()
            tempLine = nil
        }
        
        // if there is something to draw we draw our actual line Array
        if (firstPoint != nil) {
            for line in lines{
                context.move(to: line.start)
                context.addLine(to: line.end)
                context.close()
                context.stroke()
            }
        
            // possible addition: Fill surface with clicking the done button
            /* if (didDone) {
                let shapeLayer = CAShapeLayer()
                
                shapeLayer.frame = self.frame
                shapeLayer.path = context.cgPath
                shapeLayer.fillColor = UIColor.red.cgColor
                shapeLayer.strokeColor = UIColor.black.cgColor
                shapeLayer.lineCap = kCALineCapRound
                shapeLayer.lineWidth = 4
                shapeLayer.fillRule = kCAFillRuleEvenOdd
                
                self.layer.addSublayer(shapeLayer)
                self.layer.mask = shapeLayer
            } */
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    // MARK: - Actions
    /* First we set the boolean variable didClear to false because we didnt clear the canvas then we enable the redo button, then we delete the last element of the lines array and safe it in a new array "lastLines". Then we have to update our new ending point which is the end of the new last element of the line array. Then we redraw everything, after that we check if there is only one line left in line array. If thats the case then we'll disable the undo Button (See: func CheckIfSingleLineDrawn()) */
    func undo() {
        didClear = false
        removedLines.append(lines.popLast()!)
        firstPoint = lines.last?.end
        setNeedsDisplay()
        checkIfSingleLineDrawn()
        delegate?.didMakeChange()
        delegate?.shouldSetRedoButton(true)
    }
    
    /* First we ask wether we clear the canvas or iv we've undone the last drawn line.
        !didClear: we insert the last element of the last deleted lines array in our lines array.
        didClear: we assign every line we deleted to the lines array then we assign endpoint of the last element of lines array to the firstPoint. Then we delete everything in lastLines because we've already redone everything there was
     
     Then we set the Boolean variable firstLine to false to signal that we dont draw the first line. Then we set did clear to false again. Then we redraw. At the end we check if there is only one Line on our View */
    func redo() {
        if !didClear {
            lines.append(removedLines.removeLast())
        } else {
            lines = removedLines
            firstPoint = lines.last?.end
            removedLines.removeAll()
        }
        
        if removedLines.isEmpty {
            delegate?.shouldSetRedoButton(false)
        } else {
            delegate?.shouldSetRedoButton(true)
        }
        
        isFirstLine = false
        didClear = false
        setNeedsDisplay()
        checkIfSingleLineDrawn()
        delegate?.didMakeChange()
        delegate?.shouldSetClearButton(true)
    }

    /* When clearButton is triggered we set didClear to true and we save everything we are going to delete in the last lines array. The array of lines is resetted the boolean to determine wether we draw the first line is set to true. Then we force the system to redraw the empty line array with setNeedsDisplay() */
    func clear() {
        didClear = true
        removedLines = lines
        lines = []
        isFirstLine = true
        setNeedsDisplay()
        delegate?.didMakeChange()
        delegate?.shouldSetUndoButton(false)
        delegate?.shouldSetRedoButton(true)
        delegate?.shouldSetClearButton(false)
        delegate?.shouldSetDoneButton(false)
    }
    
    func done() {
        if let initialAndEndPoint = getIntersectionPoint(firstLine: lines.first!, lastLine: lines.last!) {
            // didDone = true
            lines.first?.start = initialAndEndPoint
            lines.last?.end = initialAndEndPoint
            setNeedsDisplay()
            delegate?.didMakeChange()
        }
    }
    
    // populates the lines array with given (saved) content
    func setContent(blueprint: [Line]?) {
        didClear = true
        removedLines = []
        lines = blueprint ?? []
        isFirstLine = true
        
        if !lines.isEmpty {
            isFirstLine = false
            firstPoint = lines.last!.end
            
            switch lines.count {
            case 1:
                delegate?.shouldSetClearButton(true)
                delegate?.shouldSetUndoButton(false)
                delegate?.shouldSetDoneButton(false)
            case 2:
                delegate?.shouldSetClearButton(true)
                delegate?.shouldSetUndoButton(true)
                delegate?.shouldSetDoneButton(false)
            case 3...Int.max:
                delegate?.shouldSetClearButton(true)
                delegate?.shouldSetUndoButton(true)
                delegate?.shouldSetDoneButton(true)
            default:
                break
            }
        } else {
            isFirstLine = true
            delegate?.shouldSetClearButton(false)
            delegate?.shouldSetUndoButton(false)
            delegate?.shouldSetDoneButton(false)
        }
        
        setNeedsDisplay()
    }
    
    func getContent() -> [Line]? {
        if !lines.isEmpty {
            return lines
        } else {
            return nil
        }
    }
    
    func setStroke(color: UIColor) {
        self.strokeColor = color
    }
    
    // MARK: - Private Actions
    /*
        Problem: we couldn't redraw if we deletet all lines with 'undo'.
        Solution: if we disable undo if there is only one line left everything works fine
     */
    private func checkIfSingleLineDrawn() {
        if lines.count == 1 {
            delegate?.shouldSetUndoButton(false)
        } else {
            delegate?.shouldSetUndoButton(true)
        }
    }
    
    // returns 2 aligned (Vertical, Horizontal, Diagonal) points.
    private func getLine(firstPoint: CGPoint, lastPoint: CGPoint) -> (CGPoint, CGPoint) {
        var newLastPoint = CGPoint(x: 0, y: 0)
        
        if (drawVertical && !drawDiagonal) {
            // vertically
            newLastPoint = CGPoint(x: firstPoint.x, y: lastPoint.y)
        } else if (!drawVertical && !drawDiagonal) {
            // horizontally
            newLastPoint = CGPoint(x: lastPoint.x, y: firstPoint.y)
        } else {
            // 45 degrees (x coordinate from firstpoint + the distance to the lastpoint on the x-axis ... same with y
            if (lastPoint.x < firstPoint.x) {
                newLastPoint = CGPoint(x: firstPoint.x - abs(lastPoint.y - firstPoint.y), y: lastPoint.y)
            } else if (lastPoint.x > firstPoint.x) {
                newLastPoint = CGPoint(x: firstPoint.x + abs(lastPoint.y - firstPoint.y), y: lastPoint.y)
            }
        }
        
        return (firstPoint, newLastPoint)
    }
    
    /* Determines the intersection point of the first and the last line with simple linear functions. We only have to consider the alignments of both lines in order to apply the right functions */
    private func getIntersectionPoint(firstLine: Line, lastLine: Line) -> CGPoint? {
        var interSectionPoint: CGPoint?
        
        switch (determineLineDirection(firstLine)) {
        case 1:
            // firstline is vertical
            switch (determineLineDirection(lastLine)) {
            case 1:
                interSectionPoint = firstLine.start
            case 2:
                interSectionPoint = CGPoint(x: firstLine.start.x, y: lastLine.start.y)
            case 3:
                interSectionPoint = CGPoint(x: firstLine.start.x ,y: functionYValue(xValue: firstLine.start.x, line: lastLine))
            default:
                break
            }
        case 2:
            // firstline is horizontal
            switch (determineLineDirection(lastLine)) {
            case 1:
                interSectionPoint = CGPoint(x: lastLine.start.x, y: firstLine.start.y)
            case 2:
                interSectionPoint = firstLine.start
            case 3:
                interSectionPoint = CGPoint(x: functionXValue(yValue: firstLine.start.y, line: lastLine), y: firstLine.start.y)
            default:
                break
            }
        case 3:
            switch (determineLineDirection(lastLine)) {
            // firstline is diagonal
            case 1:
                interSectionPoint = CGPoint(x: lastLine.start.x, y: functionYValue(xValue: lastLine.start.x, line: firstLine))
            case 2:
                interSectionPoint = CGPoint(x: functionXValue(yValue: lastLine.start.y, line: firstLine),y: lastLine.start.y)
            case 3:
                interSectionPoint = firstLine.start
            default:
                break
            }
        default:
            break
        }
        
        return interSectionPoint
    }
    
    private func determineLineDirection(_ line: Line) -> Int {
        if line.start.x == line.end.x {
            // vertical
            return 1
        } else if line.start.y == line.end.y {
            // horizontal
            return 2
        } else {
            // diagonal
            return 3
        }
    }
    
    private func functionYValue(xValue x: CGFloat, line: Line) -> CGFloat {
        // f(x) = mx+b
        // b = y-x
        let b = line.start.y - line.start.x
        return x + b
    }
    
    private func functionXValue(yValue y: CGFloat, line: Line) -> CGFloat {
        // f(x) = mx+b
        // b = f(x)-x
        // x = y-b
        let b = line.start.y - line.start.x
        return y - b
    }
    
}

protocol DrawViewDelegate {
    func didMakeChange()
    func shouldSetUndoButton(_ state: Bool)
    func shouldSetRedoButton(_ state: Bool)
    func shouldSetClearButton(_ state: Bool)
    func shouldSetDoneButton(_ state: Bool)
}
