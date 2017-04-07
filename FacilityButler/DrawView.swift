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
        delegate?.didDrawFirstLine()
        
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
    
    // MARK: - Actions
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
    func didDrawFirstLine()
}
