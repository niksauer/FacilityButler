//
//  Line.swift
//  FacilityButler
//
//  Created by Malcolm Malam on 06.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class Line: NSObject, NSCoding {
    
    // MARK: - Instance Properties
    var start: CGPoint
    var end: CGPoint
    
    // MARK: - Initialization
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    // MARK: - NSCoding Protocol
    required convenience init?(coder aDecoder: NSCoder) {
        if let start = aDecoder.decodeObject(forKey: PropertyKey.lineStart) as? String, let end = aDecoder.decodeObject(forKey: PropertyKey.lineEnd) as? String {
            self.init(start: CGPointFromString(start), end: CGPointFromString(end))
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        let startValue = NSStringFromCGPoint(start)
        let endValue = NSStringFromCGPoint(end)
        
        aCoder.encode(startValue, forKey: PropertyKey.lineStart)
        aCoder.encode(endValue, forKey: PropertyKey.lineEnd)
    }
}
