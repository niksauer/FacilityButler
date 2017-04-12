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
    var didDone = false
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
    
    /*
    // TODO
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first?.location(in: self)
        
        if (self.bounds.contains(lastPoint)) {
            let (initialPoint, endPoint) = getLine(firstPoint: firstPoint, lastPoint: lastPoint)
            lines.append(Line(start: initialPoint, end: endPoint))
            firstPoint = endPoint
            delegate?.didDrawLine()
            lastLines.removeAll()
            checkIfSingleLineDrawn()
            
            setNeedsDisplay()
        } else {
            print("line not in view")
        }
    }
    */
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // last point gets the value of the last point we touched
        lastPoint = touches.first?.location(in: self)
        
        if (self.bounds.contains(lastPoint)) {
            let (initialPoint, endPoint) = getLine(firstPoint: firstPoint, lastPoint: lastPoint)
            lines.append(Line(start: initialPoint, end: endPoint))
            firstPoint = endPoint
            
            delegate?.didDrawLine()
            
            if lines.count > 2 {
                delegate?.shouldSetDoneButton(true)
            } else {
                delegate?.shouldSetDoneButton(false)
            }
            
            lastLines.removeAll()
            checkIfSingleLineDrawn()
            
            setNeedsDisplay()
        } else {
            //            log.debug("line not within bounds")
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIBezierPath()//UIGraphicsGetCurrentContext()
        
        //context.beginPath()
        
        if (firstPoint != nil) {
            for line in lines{
                
                
                context.move(to: line.start)
                
                
                context.addLine(to: line.end)
                context.lineWidth = 4 //setLineWidth(4)
                UIColor.black.setStroke()
                UIColor.lightGray.setFill()
                //context.setStrokeColor(UIColor.black.cgColor)
                //context.etFillColor(UIColor.lightGray.cgColor)
                context.lineCapStyle = .round //setLineCap(CGLineCap.round)
                context.lineJoinStyle = .round
                context.close()
                if(didDone){
                    context.stroke()
                    context.fill()
                }else{
                    context.stroke()
                }
                
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
        
        if lastLines.isEmpty {
            delegate?.shouldSetRedoButton(false)
        } else {
            delegate?.shouldSetRedoButton(true)
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
    
    func done() {
        if let initialAndEndPoint = getIntersectionPoint(firstLine: lines.first!, lastLine: lines.last!) {
            didDone = true
            lines.first?.start = initialAndEndPoint
            lines.last?.end = initialAndEndPoint
            setNeedsDisplay()
        }
    }
    
    func setContent(blueprint: [Line]?) {
        clear()
        lines = blueprint ?? []
        
        if !lines.isEmpty {
            firstLine = false
            firstPoint = lines.last!.end
        } else {
            firstLine = true
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
    
    
    func  getIntersectionPoint(firstLine fl: Line, lastLine ll: Line) ->CGPoint?{
        var interSectionPoint: CGPoint? = nil
        
        
        switch(determineLineDirection(Line: fl)){
        case 1:
            //firstline is vertical
            switch(determineLineDirection(Line: ll)){
            case 1: interSectionPoint = fl.start
            case 2: interSectionPoint = CGPoint(x: fl.start.x, y: ll.start.y)
            case 3: interSectionPoint = CGPoint(x: fl.start.x ,y: functionYValue(xValue: fl.start.x, line: ll) )
            default: break
            }
            
            
            
            
        case 2:
            //firstline is horizontal
            switch(determineLineDirection(Line: ll)){
            case 1: interSectionPoint = CGPoint(x: ll.start.x, y: fl.start.y)
            case 2: interSectionPoint = fl.start
            case 3: interSectionPoint = CGPoint(x: functionXValue(yValue: fl.start.y, line: ll), y: fl.start.y)
            default: break
            }
            
            
            
        case 3:
            switch(determineLineDirection(Line: ll)){
            //firstline is diagonal
            case 1: interSectionPoint = CGPoint(x: ll.start.x, y: functionYValue(xValue: ll.start.x, line: fl))
            case 2: interSectionPoint = CGPoint(x: functionXValue(yValue: ll.start.y, line: fl),y: ll.start.y)
            case 3: interSectionPoint = fl.start
            default: break
            }
            
        default: break
        }
        
        return interSectionPoint
        
    }
    
    private func determineLineDirection(Line line: Line) -> Int{
        if(line.start.x == line.end.x){
            //vertical
            return 1
        }
        else if(line.start.y == line.end.y){
            //horizontal
            return 2
        }
        else{
            //diagonal
            return 3
        }
        
        
    }
    
    private func functionYValue(xValue x: CGFloat, line diagLine: Line) -> CGFloat{
        //f(x)=mx+b (b = y-x)
        var b: CGFloat
        b = diagLine.start.y - diagLine.start.x
        
        return x + b
        
    }
    
    private func functionXValue(yValue y: CGFloat, line diagLine: Line) -> CGFloat{
        //f(x)=mx+b (b = y-x) (x = y-b)
        var b: CGFloat
        b = diagLine.start.y - diagLine.start.x
        
        
        return y - b
        
    }
    
}

protocol DrawViewDelegate {
    func didDrawLine()
    func shouldSetRedoButton(_ state: Bool)
    func shouldSetUndoButton(_ state: Bool)
    func shouldSetDoneButton(_ state: Bool)
}
